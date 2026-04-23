# AGENTS.md

Guidance for AI coding agents (Claude Code, Codex, Cursor, Copilot, Gemini CLI, and others)
working in this repository. Loaded into agent context automatically — keep it concise.

## Overview

Cadence smart-contract project that provides a mock of the mainnet `EVMVMBridgedToken_USDF`
fungible token so the **same** scripts and transactions run unmodified against emulator,
testnet, and mainnet. The mock contract is named with the mainnet contract's exact identifier
(`EVMVMBridgedToken_2aabea2058b5ac2d339b163c6ab6f2b6d53aabed`) and re-uses the mainnet storage
paths; per-network aliases in `flow.json` route imports to the real contract on mainnet and
to the mock on emulator. See `DOCS.md` for the full design rationale.

## Build and Test Commands

Commands come from the Flow CLI (no Makefile or `package.json` in this repo).

- `flow emulator` — start a local Flow emulator (the README says `flow emulator --start`; the
  correct command is `flow emulator`).
- `flow project deploy --network=emulator` — deploy `USDF_MOCK.cdc` to the emulator account
  defined in `flow.json` (`deployments.emulator.emulator-account`).
- `flow scripts execute cadence/scripts/GetUSDFMockBalance.cdc --arg Address:0x<addr>` —
  read a vault balance.
- `flow scripts execute cadence/scripts/GetUSDFMockInfo.cdc` — read token name/symbol/decimals/totalSupply.
- `flow transactions send cadence/transactions/SetupUSDFMockVault.cdc` — create a vault +
  public capabilities in the signer's account.
- `flow transactions send cadence/transactions/MintUSDFMock.cdc <amount> <recipient>` — mint
  up to 1000 tokens per call and deposit into `recipient`'s vault.
- `flow test` — would run tests under `cadence/tests/_test.cdc`, but **no `cadence/tests/`
  directory exists in this repo** (the README's testing section is boilerplate).

Add `--network=testnet` or `--network=mainnet` on scripts/transactions to target those
networks; note `flow.json` has no `testnet` alias for the mock, and no `testnet` entry under
`deployments`, so the mock cannot be deployed with `flow project deploy --network=testnet`
without adding one.

## Architecture

```
cadence/
  contracts/USDF_MOCK.cdc              Mock USDF FungibleToken contract (public mint, 6 decimals)
  scripts/GetUSDFMockBalance.cdc       Read a vault's balance by address
  scripts/GetUSDFMockInfo.cdc          Read name/symbol/decimals/totalSupply via FTDisplay
  transactions/SetupUSDFMockVault.cdc  Create vault + publish Vault & Receiver capabilities
  transactions/MintUSDFMock.cdc        Public-mint and deposit into recipient
flow.json                              Contract alias + dependencies + emulator deployment
DOCS.md                                Design guide for mainnet-compatible mock contracts
README.md                              Generic Flow starter-kit README (partly boilerplate)
```

`flow.json` contract aliases for the mock:

- emulator → `0xf8d6e0586b0a20c7`
- testing  → `0x0000000000000007`
- mainnet  → `0x1e4aa0b87d10b141`

Declared dependencies (pulled via `flow deps`): `Burner`, `CrossVMMetadataViews`, `EVM`,
`FlowStorageFees`, `FlowToken`, `FungibleToken`, `FungibleTokenMetadataViews`,
`FungibleTokenSwitchboard`, `MetadataViews`, `NonFungibleToken`, `ViewResolver`.

## Conventions and Gotchas

- **Never rename the contract.** The identifier
  `EVMVMBridgedToken_2aabea2058b5ac2d339b163c6ab6f2b6d53aabed` must match the mainnet contract
  byte-for-byte for the `flow.json` alias routing to work (see `DOCS.md` §1).
- **Use hard-coded storage/public paths**, not `Contract.VaultStoragePath` constants. All
  scripts and transactions in this repo use literal paths like
  `/public/EVMVMBridgedToken_2aabea2058b5ac2d339b163c6ab6f2b6d53aabedVault`; the mainnet
  contract may not expose path constants publicly (see `DOCS.md` §5).
- **Public mint is a mock-only convenience.** `mintTokens(amount:)` in `USDF_MOCK.cdc` is
  callable by anyone and capped at 1000 tokens/call; the real mainnet contract requires a
  `Minter` resource and admin authorization. Any transaction that relies on public minting
  will fail on mainnet.
- **Mock decimals are 6.** `GetUSDFMockInfo.cdc` hard-codes `decimals: 6` as a fallback
  because the mainnet contract may not expose `getDecimals()` at the contract level.
- **`MintUSDFMock.cdc` panics if the recipient has no vault.** Run `SetupUSDFMockVault.cdc`
  on the recipient account first.
- **Burning.** `Vault.burnCallback()` is invoked by `Burner.burn()`; do not call `destroy`
  on vaults directly — route burns through the `Burner` contract so `totalSupply` is
  decremented and `TokensBurned` is emitted.
- **README drift.** `README.md` references `Counter.cdc`, `GetCounter.cdc`,
  `IncrementCounter.cdc`, and `cadence/tests/Counter_test.cdc` — none exist. Treat those
  sections as template boilerplate, not spec.
- **`imports/` is generated.** `.gitignore` excludes `imports` (the dir Flow CLI writes
  dependency contracts into) but `.cursorignore` forces `!imports` so AI tools can still
  read them. Do not commit `imports/` contents.

## Files Not to Modify

- `emulator-account.pkey` — emulator private key (gitignored).
- `imports/` — generated dependency sources fetched by `flow deps`.
- `.audit-extract.json`, `SEO_AUDIT_REPORT.md` — audit artifacts (untracked).
