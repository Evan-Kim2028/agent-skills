# Surface index

Each pass → one file. Load **only** passes for this run. Cite rule `slug` in findings.

| Pass | File | Default (`release`) | Default (`taste`) |
|------|------|---------------------|-------------------|
| `touch` | `touch.md` | on | on |
| `a11y` | `a11y.md` | on | on |
| `data` | `data-display.md` | on | on |
| `forms` | `forms-keyboard.md` | on | on |
| `scroll` | `scroll-layout.md` | on | on |
| `feedback` | `feedback-async.md` | on | on |
| `platform` | `platform-chrome.md` | on | on |
| `motion` | `motion.md` | off | on |
| `perf` | `performance-feel.md` | off | on |
| `trust` | `trust-safety.md` | on | on |
| `charts` | `charts-numbers.md` | on if data-viz/numeric surfaces in scope | on |

## Hunt order (when running full default set)

1. touch  
2. a11y  
3. data  
4. forms  
5. scroll  
6. feedback  
7. platform  
8. trust  
9. charts (if data-viz/numeric surfaces in scope)  
10. motion (taste)  
11. perf (taste)

## Rule format (every surface file)

**slug** · severity · effort · Fix in one phrase · **Detect** · **Hunt** · **Why** · **Gotchas**  
Multi-severity rules: Critical on primary path; else the lower severity.
