#!/usr/bin/env python3
"""Site-style Reel storyboard: ~1fps frames + timed VO transcript.

Usage:
  python storyboard_reel.py --out /tmp/reel_storyboards reel1.mp4 [reel2.mp4 ...]
  python storyboard_reel.py --out /tmp/out --ffmpeg /tmp/ffmpeg --model base reel.mp4

Requires: ffmpeg/ffprobe on PATH (or --ffmpeg/--ffprobe), faster-whisper installed
in the active Python env.
"""
from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
from pathlib import Path


def find_bin(name: str, override: str | None) -> str:
    if override:
        return override
    found = shutil.which(name)
    if found:
        return found
    # common static download location used in agent sessions
    candidate = Path(f"/tmp/{name}")
    if candidate.is_file():
        return str(candidate)
    raise SystemExit(
        f"Missing `{name}`. Install ffmpeg or pass --{name} /path/to/{name}"
    )


def probe_duration(ffprobe: str, path: str) -> float:
    r = subprocess.run(
        [
            ffprobe,
            "-v",
            "error",
            "-show_entries",
            "format=duration",
            "-of",
            "default=noprint_wrappers=1:nokey=1",
            path,
        ],
        capture_output=True,
        text=True,
    )
    if r.returncode == 0 and r.stdout.strip():
        return float(r.stdout.strip())
    # fallback parse ffmpeg -i
    r2 = subprocess.run([ffprobe.replace("ffprobe", "ffmpeg"), "-i", path], capture_output=True, text=True)
    for line in (r2.stderr or "").splitlines():
        if "Duration:" in line:
            part = line.split("Duration:")[1].split(",")[0].strip()
            h, m, s = part.split(":")
            return int(h) * 3600 + int(m) * 60 + float(s)
    raise SystemExit(f"Could not probe duration: {path}")


def extract_frames(ffmpeg: str, src: str, frames_dir: Path, times: list[float]) -> None:
    frames_dir.mkdir(parents=True, exist_ok=True)
    for old in frames_dir.glob("*.jpg"):
        old.unlink()
    for t in times:
        label = str(t).replace(".", "p")
        out = frames_dir / f"t{label}.jpg"
        subprocess.run(
            [
                ffmpeg,
                "-y",
                "-ss",
                str(t),
                "-i",
                src,
                "-frames:v",
                "1",
                "-q:v",
                "5",
                str(out),
            ],
            capture_output=True,
            check=False,
        )


def frame_times(duration: float) -> list[float]:
    times: list[float] = [0.05]
    t = 1
    while t <= int(duration):
        times.append(float(t))
        t += 1
    end = round(max(duration - 0.1, 0.05), 2)
    if times[-1] < end - 0.05:
        times.append(end)
    return times


def transcribe(path: str, model_size: str) -> list[dict]:
    try:
        from faster_whisper import WhisperModel
    except ImportError as e:
        raise SystemExit(
            "faster-whisper not installed. "
            "python -m venv /tmp/reelvenv && /tmp/reelvenv/bin/pip install faster-whisper"
        ) from e
    model = WhisperModel(model_size, device="cpu", compute_type="int8")
    segments, _info = model.transcribe(
        path, language="en", word_timestamps=False, vad_filter=True
    )
    out = []
    for seg in segments:
        out.append(
            {
                "start": round(seg.start, 2),
                "end": round(seg.end, 2),
                "text": seg.text.strip(),
            }
        )
    return out


def sparse_flags(frames_dir: Path, threshold: int = 80000) -> list[tuple[str, int, bool]]:
    rows = []
    for f in sorted(frames_dir.glob("*.jpg")):
        size = f.stat().st_size
        rows.append((f.name, size, size < threshold))
    return rows


def write_storyboard(
    name: str,
    duration: float,
    times: list[float],
    segs: list[dict],
    frames_dir: Path,
    out_md: Path,
) -> None:
    lines = [
        f"# {name} storyboard",
        f"Duration: {duration:.2f}s",
        f"Frames: {len(list(frames_dir.glob('*.jpg')))} @ ~1fps",
        "",
        "## Transcript",
        "",
    ]
    for s in segs:
        lines.append(f"- **{s['start']:.2f}–{s['end']:.2f}s**: {s['text']}")
    lines += ["", "## Frame index", ""]
    for t in times:
        fn = f"t{str(t).replace('.', 'p')}.jpg"
        lines.append(f"- {t}s → frames/{fn}")
    lines += ["", "## Sparse-frame proxy (bytes < 80KB)", ""]
    for name_f, size, sparse in sparse_flags(frames_dir):
        flag = " **SPARSE?**" if sparse else ""
        lines.append(f"- `{name_f}` {size}{flag}")
    out_md.write_text("\n".join(lines) + "\n")


def process_one(
    path: Path,
    out_root: Path,
    ffmpeg: str,
    ffprobe: str,
    model_size: str,
) -> None:
    name = path.stem
    vdir = out_root / name
    frames_dir = vdir / "frames"
    vdir.mkdir(parents=True, exist_ok=True)

    duration = probe_duration(ffprobe, str(path))
    times = frame_times(duration)
    print(f"=== {name} duration={duration:.2f}s frames={len(times)} ===")
    extract_frames(ffmpeg, str(path), frames_dir, times)
    segs = transcribe(str(path), model_size)
    (vdir / "transcript.json").write_text(json.dumps(segs, indent=2))
    write_storyboard(name, duration, times, segs, frames_dir, vdir / "STORYBOARD.md")
    for s in segs:
        print(f"  [{s['start']:5.2f}-{s['end']:5.2f}] {s['text']}")
    sparse = [r for r in sparse_flags(frames_dir) if r[2]]
    if sparse:
        print(f"  sparse candidates: {', '.join(x[0] for x in sparse)}")
    print(f"  wrote {vdir}/STORYBOARD.md")


def main() -> None:
    ap = argparse.ArgumentParser(description="1fps + Whisper storyboard for Reels")
    ap.add_argument("videos", nargs="+", type=Path, help="Input .mp4 paths")
    ap.add_argument("--out", type=Path, default=Path("/tmp/reel_storyboards"))
    ap.add_argument("--ffmpeg", default=None)
    ap.add_argument("--ffprobe", default=None)
    ap.add_argument("--model", default="base", help="faster-whisper model size")
    args = ap.parse_args()

    ffmpeg = find_bin("ffmpeg", args.ffmpeg)
    try:
        ffprobe = find_bin("ffprobe", args.ffprobe)
    except SystemExit:
        # some static builds ship ffprobe next to ffmpeg
        sibling = Path(ffmpeg).with_name("ffprobe")
        if sibling.is_file():
            ffprobe = str(sibling)
        else:
            ffprobe = ffmpeg  # probe_duration has ffmpeg -i fallback via replace hack
            # fix: pass ffmpeg path as ffprobe and use -i fallback only
            ffprobe = ffmpeg

    args.out.mkdir(parents=True, exist_ok=True)
    for vid in args.videos:
        if not vid.is_file():
            print(f"skip missing: {vid}", file=sys.stderr)
            continue
        process_one(vid, args.out, ffmpeg, ffprobe, args.model)
    print("DONE")


if __name__ == "__main__":
    main()
