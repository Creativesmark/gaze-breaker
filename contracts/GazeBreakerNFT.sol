// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * GazeBreakerNFT (Soul Badge)
 * - Players mint a badge for a given level by paying 0.02 tTRUST.
 * - One badge per address per level.
 * - Non-transferable (soulbound): transfers & burns are blocked.
 * - tokenURI is picked from 8 pre-provided URIs (index = level-1).
 */
contract GazeBreakerNFT is ERC721, Ownable {
    using Counters for Counters.Counter;

    // ===== Config =====
    uint256 public constant MINT_FEE = 0.02 ether; // 0.02 tTRUST on Intuition

    // ===== State =====
    Counters.Counter private _tokenIds;
    mapping(address => mapping(uint256 => bool)) private _hasMintedLevel; // user => level => minted?
    mapping(uint256 => uint256) private _tokenLevel; // tokenId => level
    string[] private _tokenURIs; // exactly 8 entries

    event Minted(address indexed to, uint256 indexed tokenId, uint256 indexed level);
    event FundsWithdrawn(address indexed to, uint256 amount);

    constructor(string[] memory tokenURIs)
        ERC721("GazeBreakerSoulBadge", "GBSB")
        Ownable(msg.sender)
    {
        require(tokenURIs.length == 8, "Must provide 8 token URIs");
        for (uint256 i = 0; i < tokenURIs.length; i++) {
            _tokenURIs.push(tokenURIs[i]);
        }
    }

    /**
     * Mint a badge for a specific level.
     * Requirements:
     * - level in [1..8]
     * - caller pays exactly 0.02 tTRUST
     * - caller hasn't minted this level before
     */
    function mintLevel(address to, uint256 level) external payable {
        require(level >= 1 && level <= 8, "Invalid level");
        require(msg.value == MINT_FEE, "Fee is 0.02 tTRUST");
        require(to != address(0), "Invalid recipient");
        require(!_hasMintedLevel[to][level], "Level already minted");

        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();

        _hasMintedLevel[to][level] = true;
        _tokenLevel[tokenId] = level;

        // Soulbound: still mint normally; transfer is blocked by _update override below
        _safeMint(to, tokenId);

        emit Minted(to, tokenId, level);
    }

    /// View the level associated with a token.
    function levelOf(uint256 tokenId) external view returns (uint256) {
        _requireOwned(tokenId); // OZ v5 style existence check
        return _tokenLevel[tokenId];
    }

    /// tokenURI based on provided per-level URIs (index = level - 1)
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        uint256 level = _tokenLevel[tokenId];
        return _tokenURIs[level - 1];
    }

    /**
     * Soulbound enforcement (OZ v5):
     * - Block any move where `from != address(0)` (i.e., not minting).
     * - This also blocks burns (`to == address(0)`) unless you add an explicit burn function and
     *   relax the rule for that function.
     */
    function _update(address to, uint256 tokenId, address auth)
        internal
        override
        returns (address)
    {
        address from = _ownerOf(tokenId);
        if (from != address(0)) {
            revert("Soulbound: non-transferable");
        }
        return super._update(to, tokenId, auth);
    }

    /// Owner can withdraw accumulated mint fees.
    function withdraw() external onlyOwner {
        uint256 bal = address(this).balance;
        (bool ok, ) = owner().call{value: bal}("");
        require(ok, "Withdraw failed");
        emit FundsWithdrawn(owner(), bal);
    }
}
