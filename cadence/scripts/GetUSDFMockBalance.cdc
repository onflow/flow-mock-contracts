import "USDF_MOCK"

/// This script returns the balance of USDF_MOCK tokens for a given account.
/// Returns 0.0 if the account doesn't have a vault set up.
///
/// @param account: The account address to check
/// @return The balance of USDF_MOCK tokens in the account
///
access(all) fun main(account: Address): UFix64 {
    let accountRef = getAccount(account)
    
    // Try to borrow the vault reference
    if let vaultRef = accountRef.capabilities.borrow<&USDF_MOCK.Vault>(USDF_MOCK.VaultPublicPath) {
        return vaultRef.balance
    } else {
        // Account doesn't have a vault set up
        return 0.0
    }
}
