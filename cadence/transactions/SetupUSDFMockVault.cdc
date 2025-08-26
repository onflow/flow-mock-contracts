import "FungibleToken"
import "USDF_MOCK"

/// This transaction sets up a USDF_MOCK vault for the signer's account.
/// It creates the vault, saves it to storage, and creates the necessary public capabilities.
///
transaction() {

    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {
        
        // Check if account already has a vault
        if signer.storage.borrow<&USDF_MOCK.Vault>(from: USDF_MOCK.VaultStoragePath) != nil {
            log("Account already has a USDF_MOCK vault set up")
            return
        }

        // Create a new empty vault
        let vault <- USDF_MOCK.createEmptyVault(vaultType: Type<@USDF_MOCK.Vault>())

        // Save the vault to storage
        signer.storage.save(<-vault, to: USDF_MOCK.VaultStoragePath)

        // Create and publish public capabilities
        let vaultCap = signer.capabilities.storage.issue<&USDF_MOCK.Vault>(
            USDF_MOCK.VaultStoragePath
        )
        signer.capabilities.publish(vaultCap, at: USDF_MOCK.VaultPublicPath)

        let receiverCap = signer.capabilities.storage.issue<&{FungibleToken.Receiver}>(
            USDF_MOCK.VaultStoragePath
        )
        signer.capabilities.publish(receiverCap, at: USDF_MOCK.ReceiverPublicPath)

        log("USDF_MOCK vault set up successfully")
    }

    execute {
        log("Vault setup completed successfully")
    }
}
