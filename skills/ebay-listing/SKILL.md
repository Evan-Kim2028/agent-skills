---
name: ebay-listing
description: >
  List Pokémon TCG singles on the ekcope-46 eBay store via lake-of-rage
  ebay-sell (Trading AddFixedPriceItem). Groups photo dumps, IDs cards from
  catalog not vision, prices from gold + TCGPlayer + live asks, posts GTC
  listings with buyer-paid USPS First Class letter. Use when listing, drafting,
  revising, or bulk-uploading Pokémon cards on eBay; when the user gives a
  photo folder/zip; when they mention ebay-sell, Seller Hub, Magical Bulk,
  item specifics, or shipping policy. Do not post until the user confirms the
  preview. Not for buy-side Browse scrape or gold.sales ingest (pipeline skill).
---

# eBay listing (Pokémon singles)

Store: **ekcope-46**. Code: `lake-of-rage/pipelines/ebay_scraper/src/ebay_scraper/sell/`. Run CLI on **`lake-vps-lor-main`** (tokens in `~/.config/ebay/`, 0600). Never print tokens, auth codes, or street address.

Canonical policy IDs, category, and CCG descriptors live in `ebay_scraper.sell.config` and `ebay_scraper.sell.listing` — do not fork them here.

## Do not

- Post without a confirmed preview (title, condition, price, photos, shipping).
- Trust Nemotron / vision for set, number, rarity, finish, or grade.
- Call a card Reverse Holo unless the user confirms the photo is reverse.
- Use free shipping or eBay Standard Envelope as the default.
- Use Inventory `createOffer` as the happy path — this seller’s live listings are Trading. Inventory is empty until migrated.
- Print secrets or the ship-from street. Postal comes from merchant location `PRIMARY`.

## Workflow

Detail: [`references/process.md`](references/process.md).

1. **Group photos** by ~30s timestamp gaps. Inside a card: several fronts, then backs/corners. Not strict front/back pairs.
2. **Identify** from the card face + `catalog.json` (`tcg_card_id`, number, rarity). `neo3-5` is Delibird, not Shuckle (`neo3-51`).
3. **Condition** is the user’s call. Propose from photos, then wait. CCG ungraded = condition ID `4000` + descriptor `40001`.
4. **Price** from gold rollup / TCGPlayer solds / PriceCharting / live eBay asks. Do not invent BINs.
5. **Draft** titles/SKUs/specifics via `listing.py` (`build_title`, `build_sku`, `store_description`). Preview HTML before post.
6. **Post** only the cards they name: resize ≤1600px, `ebay-sell post-draft --drafts … --index N --photos …`. Default shipping policy is buyer-paid **USPS First Class letter** (~$1.40), Ground/parcel backup. Duration **GTC**.
7. **Verify** `ebay-sell listings` + `GetItemShipping` (letter ~$1.40). Direct URL is live immediately; search can lag a few minutes.

## Defaults (this store)

| Field | Value |
|---|---|
| Category | `183454` CCG singles |
| Duration | GTC (30-day clock is renewal, not expiry) |
| Shipping | Buyer pays. First Class letter first, USPS parcel second |
| Finish on eBay | `Regular` for non-holo (not `Non-Holo`) |
| Name aspect | `Card Name` (not `Character`) |
| Description | `store_description()` — photos of this copy, sleeved + toploader, USPS letter ~$1.40 |

Revise price/qty: `ebay-sell revise --item-id … --price …`. Description: `trading.revise_description`.
