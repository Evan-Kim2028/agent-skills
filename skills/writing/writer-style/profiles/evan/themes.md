# themes.md — Evan substance bank (topic tags)

Pull **fitting** examples from lived corpus themes; do not invent fake war stories.

## Data infrastructure / lakehouse
- Single-host Iceberg medallion, memory caps, lane registry, promote stagger  
- DuckDB serving on Iceberg snapshots, version-hint / metadata pointers  
- Heterogeneous marketplace ingest (on-chain + off-chain)  

## Solana data & oracles
- Failed transaction rates, Pyth receiver, validator fee incentives  
- Jito tips pipelines, Cryptohouse vs Dune, tooling series  

## MEV / blobs / L1 markets
- Reordering slippage, blob inclusion, preconfirmations, fee slippage  
- Combinatorics of slot inclusion, competitive blob markets  

## DeFi theory / AMM
- AMM design trilemma (path independence, translation invariance, liquidity sensitivity)  
- LMSR / pari-mutuel notes, CFMM IL / LVR open questions  
- Bonding curves, managed pool controllers, RMM  

## Build logs / agent tooling
- MCP for Snowflake (`igloo-mcp`), guardrails, query history JSONL  
- Agent-native data science workflows  

## Methods
- Dual-source validation; fixed slot/block ranges for cost control  
- Appendix SQL; charts as evidence  
- TL;DR bullets with units  

## Burn rates
- Don’t recycle the same 8GB lakehouse story in every piece — rotate scars.  
- One math digression per theory note max unless the piece is math-first.  
