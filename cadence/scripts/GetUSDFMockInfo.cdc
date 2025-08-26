import "USDF_MOCK"

/// This script returns information about the USDF_MOCK token.
///
/// @return A struct containing token information
///
access(all) struct TokenInfo {
    access(all) let name: String
    access(all) let symbol: String
    access(all) let decimals: UInt8
    access(all) let totalSupply: UFix64

    init(name: String, symbol: String, decimals: UInt8, totalSupply: UFix64) {
        self.name = name
        self.symbol = symbol
        self.decimals = decimals
        self.totalSupply = totalSupply
    }
}

access(all) fun main(): TokenInfo {
    return TokenInfo(
        name: USDF_MOCK.getName(),
        symbol: USDF_MOCK.getSymbol(),
        decimals: USDF_MOCK.getDecimals(),
        totalSupply: USDF_MOCK.totalSupply
    )
}
