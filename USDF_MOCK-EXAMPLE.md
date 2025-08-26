# USDF_MOCK Token Demo: Deploy and Test Mock USDF Token

This example shows how to deploy the `USDF_MOCK` contract, set up vaults, mint tokens, and interact with the mock USDF token on the Flow Emulator.

## Files used

- `cadence/contracts/USDF_MOCK.cdc`
- `cadence/transactions/SetupUSDFMockVault.cdc`
- `cadence/transactions/MintUSDFMock.cdc`
- `cadence/scripts/GetUSDFMockBalance.cdc`
- `cadence/scripts/GetUSDFMockInfo.cdc`

## Prerequisites

Install dependencies for the Flow project:

```bash
flow deps install
```

## 1) Start the emulator

```bash
flow emulator
```

Keep this running. Open a new terminal for the next steps.

## 2) Deploy the USDF_MOCK contract

```bash
flow project deploy --network emulator
```

This deploys the `USDF_MOCK` contract to the emulator (see `flow.json`).

## 3) Check initial token information

Get the token metadata to verify deployment:

```bash
flow scripts execute cadence/scripts/GetUSDFMockInfo.cdc --network emulator
```

Expected output:
```
Result: {
  "name": "USDF MOCK",
  "symbol": "USDF", 
  "decimals": 6,
  "totalSupply": "0.00000000"
}
```

## 4) Set up a vault for the emulator account

Before receiving tokens, an account needs to set up a vault:

```bash
flow transactions send cadence/transactions/SetupUSDFMockVault.cdc \
  --network emulator \
  --signer emulator-account
```

Expected: Transaction succeeds with vault setup logs.

## 5) Check initial balance (should be 0)

```bash
flow scripts execute cadence/scripts/GetUSDFMockBalance.cdc \
  --network emulator \
  --args-json '[
    {"type":"Address","value":"0xf8d6e0586b0a20c7"}
  ]'
```

Expected: `Result: 0.00000000`

Note: `0xf8d6e0586b0a20c7` is the default emulator account address.

## 6) Mint some USDF_MOCK tokens

Mint 100 tokens to the emulator account:

```bash
flow transactions send cadence/transactions/MintUSDFMock.cdc \
  --network emulator \
  --signer emulator-account \
  --args-json '[
    {"type":"UFix64","value":"100.0"},
    {"type":"Address","value":"0xf8d6e0586b0a20c7"}
  ]'
```

Notes:
- Maximum mint per transaction: 1000 tokens
- Anyone can mint tokens (public function for testing)
- Tokens are automatically deposited to the recipient's vault

## 7) Verify the tokens were minted

Check the balance again:

```bash
flow scripts execute cadence/scripts/GetUSDFMockBalance.cdc \
  --network emulator \
  --args-json '[
    {"type":"Address","value":"0xf8d6e0586b0a20c7"}
  ]'
```

Expected: `Result: 100.00000000`

## 8) Check updated total supply

Verify the total supply increased:

```bash
flow scripts execute cadence/scripts/GetUSDFMockInfo.cdc --network emulator
```

Expected:
```
Result: {
  "name": "USDF MOCK",
  "symbol": "USDF",
  "decimals": 6, 
  "totalSupply": "100.00000000"
}
```

## 9) Test with a different account (optional)

Create a new account and test the flow:

```bash
# Generate a new key pair
flow keys generate

# Create a new account (use the public key from above)
flow accounts create \
  --key <YOUR_PUBLIC_KEY> \
  --network emulator
```

Then repeat steps 4-7 with the new account address.

## 10) Advanced testing - Multiple operations

You can test various scenarios:

### Mint maximum amount:
```bash
flow transactions send cadence/transactions/MintUSDFMock.cdc \
  --network emulator \
  --signer emulator-account \
  --args-json '[
    {"type":"UFix64","value":"1000.0"},
    {"type":"Address","value":"0xf8d6e0586b0a20c7"}
  ]'
```

### Try to mint more than maximum (should fail):
```bash
flow transactions send cadence/transactions/MintUSDFMock.cdc \
  --network emulator \
  --signer emulator-account \
  --args-json '[
    {"type":"UFix64","value":"1001.0"},
    {"type":"Address","value":"0xf8d6e0586b0a20c7"}
  ]'
```

Expected: Transaction fails with error "Cannot mint more than 1000 tokens at once (for testing)"

## Contract Features

The USDF_MOCK contract provides:

- **Complete FungibleToken interface compatibility**
- **Public minting** (max 1000 tokens per transaction)
- **Standard vault operations** (deposit, withdraw, balance)
- **Metadata views** for wallet compatibility
- **Events** for all token operations
- **Interface compatibility** with original EVMVMBridgedToken_USDF

## Storage Paths

The contract uses these storage paths:
- **Vault Storage**: `/storage/USDFMockVault`
- **Vault Public**: `/public/USDFMockVault`
- **Receiver Public**: `/public/USDFMockReceiver`
- **Minter Storage**: `/storage/USDFMockMinter`

## Token Details

- **Name**: "USDF MOCK"
- **Symbol**: "USDF"
- **Decimals**: 6 (same as original EVM token)
- **Initial Supply**: 0
- **Mint Limit**: 1000 tokens per transaction

## Troubleshooting

- **"Could not borrow receiver reference"**: The recipient account needs to run `SetupUSDFMockVault.cdc` first
- **"Cannot mint more than 1000 tokens"**: Reduce the mint amount or make multiple transactions
- **"Amount minted must be greater than zero"**: Use a positive number for the mint amount
- **Import errors**: Ensure all dependencies are installed with `flow deps install`
- **Account doesn't exist**: Use `flow accounts create` to create new test accounts

## Integration Testing

This mock contract can be used to test:
- dApp integrations that expect USDF tokens
- Wallet implementations
- DeFi protocols using USDF
- Cross-contract interactions
- Token transfer functionality

The contract maintains the same interface as the original EVMVMBridgedToken_USDF, making it a perfect drop-in replacement for testing environments.
