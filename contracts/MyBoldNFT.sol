// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

// We need to import the helper functions from the contract that we copy/pasted.
import {Base64} from "./libraries/Base64.sol";

contract MyBoldNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // I split the SVG at the part where it asks for the background color.
    string svgPartOne =
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='";
    string svgPartTwo =
        "'/><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    string[] firstWords = [
        "Celebrate",
        "Push",
        "Love",
        "Appreciate",
        "Pray For",
        "Applaud",
        "Respect",
        "Honour"
    ];
    string[] secondWords = [" Yourself", " Others", " All Men", " Everyone"];

    // Get fancy with it! Declare a bunch of colors.
    string[] colors = [
        "pink",
        "red",
        "#08C2A8",
        "black",
        "yellow",
        "blue",
        "green"
    ];

    event NewBoldNFTMinted(address sender, uint256 tokenId);

    constructor() ERC721("BoldNFT", "BOLD") {
        console.log("This is my NFT Contract. Yeah!!!");
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    // I create a function to randomly pick a word from each array.
    function pickRandomFirstWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        // I seed the random generator. More on this in the lesson.
        uint256 rand = random(
            string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId)))
        );
        // Squash the # between 0 and the length of the array to avoid going out of bounds.
        rand = rand % firstWords.length;
        return firstWords[rand];
    }

    function pickRandomSecondWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId)))
        );
        rand = rand % secondWords.length;
        return secondWords[rand];
    }

    // Same old stuff, pick a random color.
    function pickRandomColor(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("COLOR", Strings.toString(tokenId)))
        );
        rand = rand % colors.length;
        return colors[rand];
    }

    function mintABoldNFT() public {
        // Get the current tokenId, this starts at 0.
        uint256 newNftId = _tokenIds.current();

        string memory first = pickRandomFirstWord(newNftId);
        string memory second = pickRandomSecondWord(newNftId);
        string memory combinedWord = string(abi.encodePacked(first, second));

        string memory randomColor = pickRandomColor(newNftId);

        string memory finalSvg = string(
            abi.encodePacked(
                svgPartOne,
                randomColor,
                svgPartTwo,
                combinedWord,
                "</text></svg>"
            )
        );

        console.log("\n--------------------");
        console.log(finalSvg);
        console.log("--------------------\n");

        // Get all the JSON metadata in place and base64 encode it.
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT as the generated word.
                        combinedWord,
                        '", "description": "A unique collection of motivational words for you.", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        // Just like before, we prepend data:application/json;base64, to our data.
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n--------------------");
        console.log(finalTokenUri);
        console.log("--------------------\n");

        _safeMint(msg.sender, newNftId);

        _setTokenURI(
            newNftId,
            finalTokenUri
        );

        console.log(
            "An NFT with ID %s has been minted to %s",
            newNftId,
            msg.sender
        );

        _tokenIds.increment();
        emit NewBoldNFTMinted(msg.sender, newNftId);
    }

    //Just deployed a NFT minting Smart Contract to the Ethereum Testnet. WAGMI
    //https://firebasestorage.googleapis.com/v0/b/bookie-1c21e.appspot.com/o/boldNFT%2Favatar03.png?alt=media&token=0fbea76f-7473-4cfe-8396-da697bac867a
}

//https://rinkeby.rarible.com/token/0x283e30ec551775A48558ECFa8f567F2538Fb5128:0
//data:application/json;base64,ewogICAgIm5hbWUiOiAiRXBpY0xvcmRIYW1idXJnZXIiLAogICAgImRlc2NyaXB0aW9uIjogIkFuIE5GVCBmcm9tIHRoZSBoaWdobHkgYWNjbGFpbWVkIHNxdWFyZSBjb2xsZWN0aW9uIiwKICAgICJpbWFnZSI6ICJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY2lJSEJ5WlhObGNuWmxRWE53WldOMFVtRjBhVzg5SW5oTmFXNVpUV2x1SUcxbFpYUWlJSFpwWlhkQ2IzZzlJakFnTUNBek5UQWdNelV3SWo0S0lDQWdJRHh6ZEhsc1pUNHVZbUZ6WlNCN0lHWnBiR3c2SUhkb2FYUmxPeUJtYjI1MExXWmhiV2xzZVRvZ2MyVnlhV1k3SUdadmJuUXRjMmw2WlRvZ01UUndlRHNnZlR3dmMzUjViR1UrQ2lBZ0lDQThjbVZqZENCM2FXUjBhRDBpTVRBd0pTSWdhR1ZwWjJoMFBTSXhNREFsSWlCbWFXeHNQU0p3ZFhKd2JHVWlJQzgrQ2lBZ0lDQThkR1Y0ZENCNFBTSTFNQ1VpSUhrOUlqVXdKU0lnWTJ4aGMzTTlJbUpoYzJVaUlHUnZiV2x1WVc1MExXSmhjMlZzYVc1bFBTSnRhV1JrYkdVaUlIUmxlSFF0WVc1amFHOXlQU0p0YVdSa2JHVWlQa1Z3YVdOTWIzSmtTR0Z0WW5WeVoyVnlQQzkwWlhoMFBnbzhMM04yWno0PSIKfQ==

//Cowboy
//https://rinkeby.rarible.com/collection/0x6685cbce8f0161e25e8afd12d7af5fa12575cbd0/items

//EpicLordHamburger
//https://rinkeby.rarible.com/search/collections/0x08533A050E10153dD19B7d83f607a8b3E9Bf499D
