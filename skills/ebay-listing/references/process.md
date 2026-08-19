# eBay listing process

Implementation: `lake-of-rage/pipelines/ebay_scraper/src/ebay_scraper/sell/`.
Run on `ssh lake-vps-lor-main` with `PYTHONPATH=pipelines/ebay_scraper/src` and the lake venv.

```
python -m ebay_scraper.sell.cli <cmd>
```

Tokens: `~/.config/ebay/{credentials.env,sell_refresh.json,.sell_access.json}`. Never log contents.

## CLI

| Command | Use |
|---|---|
| `status` | Token health (no secrets) |
| `listings` | Active items (Trading GetMyeBaySelling) |
| `policies` | Fulfillment / payment / return / locations |
| `preview-title` | 80-char title check |
| `post-draft --drafts FILE --index N --photos …` | Upload EPS + AddFixedPriceItem |
| `revise --item-id ID --price X` | Price/qty only |

`post-draft` reads policy IDs from `config.py` (`FULFILLMENT_POLICY_ID` default = calculated USPS). Package is 11×6×1 in, 3 oz, `PackageThickEnvelope`.

## Photos

Phone dumps are **time-gapped groups**, not alternating front/back.

- Sort by filename (Pixel `PXL_YYYYMMDD_HHMMSSmmm.jpg`).
- A new card starts after a ~30s gap.
- Inside a group: several front angles, then back/corners.
- Use **all** shots of that card, front first.
- Resize long edge ≤1600, JPEG ~q88 (`convert … -resize '1600x1600>' -quality 88`) before upload.
- `pair_sequential_photos` is a naive 2-file pairer — do not use it on these dumps.

## Identity

Vision (Nemotron) hallucinates set/number and over-calls NM. Ignore it for publish.

1. Read the printed set symbol, number, and rarity mark on the photo.
2. Resolve `tcg_card_id` in `/home/evan/data/pokemontcg_pipe/cards/catalog.json`.
3. Confirm finish with the user (regular vs reverse). DP-era rares look foil-ish; do not assume reverse.
4. Common trap: `neo3-5` = Delibird Rare Holo; Shuckle is `neo3-51` Common (`51/64`).

## Condition (CCG)

Ungraded only unless the user has a slab.

| User grade | Descriptor `40001` value | Aspect text (do not send as a specific — it is a descriptor) |
|---|---|---|
| NM | `400010` | Near Mint or Better |
| LP | `400015` | Lightly Played (Excellent) |
| MP | `400016` | Moderately Played (Very Good) |
| HP / DMG | `400017` | Heavily Played (Poor) |

Condition ID is always `4000` (Ungraded). Sports-card values `400011–400013` are wrong for cat `183454`.

Propose from photos, then **wait**. User overrides.

## Pricing

Never guess. Pull in this order:

1. Gold `card_rollup` / `card_finish_prices` on the VPS (`tcg_card_id`, finish, NM/LP).
2. TCGPlayer product solds + current market (via PriceCharting “TCGPlayer” rows if the site JS is empty).
3. Live eBay BIN cluster for the same number/set/finish/condition.

BIN is the item price; buyer also pays USPS. Match the store’s existing $2–$3 raw-card band unless comps say otherwise.

## Title, SKU, specifics

Title (`build_title`, ≤80): `Name Number Set [Rarity] Finish Condition`.

SKU (`build_sku`): `{tcg_card_id}-{finish}-{condition}` lowercase.

Item specifics to send:

- Game = Pokémon TCG
- Set, Card Number, **Card Name** (map from Character)
- Finish = `Regular` if non-holo; `Holo` / `Reverse Holo` only when true
- Language = English, Graded = No, Rarity
- Manufacturer = The Pokémon Company, Card Type = Pokémon
- Drop the Card Condition aspect (descriptor covers it)

Description: `store_description()` — exact-copy photos, sleeve + toploader, USPS letter ~$1.40, combined shipping. Do not say free shipping.

## Shipping (buyer pays)

Default fulfillment policy: calculated USPS.

1. `USPSFirstClassLetter` — ~$1.40 (what search shows)
2. `USPSParcel` — Ground backup ~$5.17–$5.97

GTC listings still show a ~30-day `EndTime`; that is the monthly renewal, not takedown.

Do not use `US_eBayStandardEnvelope` / eBay Send as default.

## APIs

- **Create / photos / GTC list:** Trading `UploadSiteHostedPictures` + `AddFixedPriceItem` with `SellerProfiles` (payment / return / fulfillment IDs from config).
- **Revise price/qty:** Trading `ReviseItem`. Description: `ReviseFixedPriceItem` + CDATA.
- **Read live listings:** `GetMyeBaySelling`. Inventory GET is empty until items are migrated onto Inventory SKUs.
- Business policies are required on this account — do not send legacy ShippingDetails without a profile ID.

## Verify after post

- `listings` includes the new `item_id` / view URL.
- `GetItem`: duration GTC, 4000 + `40001`/`400010|400015|…`, Finish Regular, Card Name set.
- `GetItemShipping` to 10001: first option First Class letter ~$1.40.

Seller Hub and the item URL are live immediately. Search index can take minutes.
