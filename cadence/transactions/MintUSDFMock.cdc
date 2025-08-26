import "FungibleToken"
import "USDF_MOCK"

/// This transaction mints USDF_MOCK tokens and deposits them into the recipient's vault.
/// If the recipient doesn't have a vault set up, the transaction will create one for them.
///
/// @param amount: The amount of tokens to mint (limited to 1000.0 per transaction for testing)
/// @param recipient: The address to receive the minted tokens
///
transaction(amount: UFix64, recipient: Address) {

    let recipientVault: &{FungibleToken.Receiver}

    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue) &Account) {
        
        // Get the recipient's account
        let recipientAccount = getAccount(recipient)

        // Check if recipient has a vault capability
        self.recipientVault = recipientAccount.capabilities.borrow<&{FungibleToken.Receiver}>(
            USDF_MOCK.ReceiverPublicPath
        ) ?? panic("Could not borrow receiver reference to recipient's vault")
    }

    execute {
        // Mint the requested amount of tokens
        let mintedVault <- USDF_MOCK.mintTokens(amount: amount)

        // Deposit the newly minted tokens into the recipient's vault
        self.recipientVault.deposit(from: <-mintedVault)

        log("Successfully minted ".concat(amount.toString()).concat(" USDF_MOCK tokens to ").concat(recipient.toString()))
    }
}
