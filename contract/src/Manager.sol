// contracts/MyNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import {SharedOwnership} from "./SharedOwnership.sol";
import {Video} from "./Video.sol";

contract Manager {

    address public videoAddress;

    // User access to the video
    // FIXME: Maybe use NFT instead allowing future resell of access token
    // FIXME: Could be interesting to add a royalties mechansm
    mapping(uint256 => mapping (address => bool)) public access;

    constructor() {
        videoAddress = address(new Video(address(this)));
    }

    function addNewVideo(
        address[] memory owners,
        uint256[] memory allocation,
        string memory name, 
        string memory category,
        string memory description,
        uint price,
        string memory videoURI
    ) public 
    {
        SharedOwnership sharedOwner = new SharedOwnership(owners, allocation);
        
        Video video = Video(videoAddress);
        uint256 videoId = video.addNewVideo(
            address(sharedOwner), 
            name,
            category,
            description,
            price,
            videoURI
        );

        // Give access to the video for all owners
        for (uint256 i = 0; i < owners.length; i++) {
            access[videoId][owners[i]] = true;
        }
    }

    function buyVideo(uint256 videoId) public payable {
        Video video = Video(videoAddress);
        bool sent = video.buy{value: msg.value}(videoId);
        require(sent, "Issue when buying");
        access[videoId][msg.sender] = true;
    }

}