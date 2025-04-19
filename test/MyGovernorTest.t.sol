//SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import {Test, console} from "forge-std/Test.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {Box} from "../src/Box.sol";
import {GovToken} from "../src/GovToken.sol";
import {Timelock} from "../src/Timelock.sol";

contract MyGovernorTest is Test {

    //deployments
    MyGovernor governor;
    Box box;
    Timelock timelock;
    GovToken govToken;

    address public USER = makeAddr("user");
    uint256 public INITIAL_SUPPLY = 100 ether;

    uint256 public constant MIN_DELAY = 3600; //1 hour after a vote passes
    uint256 public constant VOTING_DELAY = 1; // how many blocks until a vote is active
    uint256 public constant VOTING_PERIOD = 50400; //period of time for voting
    address [] proposers;
    address [] executors;

    uint256 [] values;
    bytes [] calldatas;
    address [] targets;


    function setUp() public {
        govToken = new GovToken();
        govToken.mint(USER, INITIAL_SUPPLY);

        vm.startPrank(USER);
        govToken.delegate(USER);

        timelock = new Timelock(MIN_DELAY, proposers, executors);

        governor = new MyGovernor(govToken, timelock);

        //roles
        bytes32 proporserRole = timelock.PROPOSER_ROLE();
        bytes32 executorRole = timelock.EXECUTOR_ROLE();
        bytes32 adminRole = timelock.DEFAULT_ADMIN_ROLE();

        //grant roles
        timelock.grantRole(proporserRole, address(governor));
        timelock.grantRole(executorRole, address(0));
        timelock.revokeRole(adminRole, USER);
        vm.stopPrank();

        box = new Box();
        box.transferOwnership(address(timelock));

        
    }

    function testCantUpdateBoxWithoutGovernance() public {
        vm.expectRevert();
        box.store(1);
    }

    function testGovernanceUpdatesBox() public {
        uint256 valueToStore = 888;
        string memory description = "Store 1 in box";
        bytes memory encodedFunctionCall = abi.encodeWithSignature("store(uint256)", valueToStore); //encoding the function call store from Box
        values.push(0);
        calldatas.push(encodedFunctionCall); //push because calldatas should be an array
        targets.push(address(box));

        //1. Propose to the DAO
        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        // View the state of the proposal
        //state should be pending = 0
        console.log("Proposal state:", uint256(governor.state(proposalId)));

        vm.warp(block.timestamp + governor.votingDelay() + 1);
        vm.roll(block.number + governor.votingDelay() + 1);


        //state should be active = 1
        console.log("Proposal state:", uint256(governor.state(proposalId)));

        //2. Vote
        string memory reason = "Because blue frog is cool";

        uint8 voteWay = 1; //voting for
        vm.prank(USER);
        governor.castVoteWithReason(proposalId, voteWay, reason);

        vm.warp(block.timestamp + governor.votingPeriod() + 1);
        vm.roll(block.number + governor.votingPeriod() + 1);



        //3. Queue the TX
        //hash the description
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));
        governor.queue(targets, values, calldatas, descriptionHash);

        vm.warp(block.timestamp + timelock.getMinDelay() + 1);
        vm.roll(block.number + timelock.getMinDelay() + 1);


        //4. Execute
        governor.execute(targets, values, calldatas, descriptionHash);

        console.log("Box Value: ", box.getNumber());
        assert(box.getNumber() == valueToStore);
        

    }

}