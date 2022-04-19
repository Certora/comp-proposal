// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";

import "../Proposal.sol";
import {Constants} from "../Constants.sol";
import "../interfaces/Oracle.sol";
import "../interfaces/IDelegatable.sol";
import "../interfaces/GovernorBravo.sol";

// for token amount calculations
uint256 constant ERROR_MARGIN = 10 ** 12;

contract ContractTest is Test {
    Proposal proposal;

    address[] targets;
    uint256[] values;
    string[]  signatures;
    bytes[]   calldatas;
    string    description;

    function setUp() public {
        proposal = new Proposal();
    }

    function _testTargets() internal {
        assertEq(targets[0], Constants.COMP_TOKEN);
        assertEq(targets[1], Constants.USDC_TOKEN);
        assertEq(targets[2], Constants.SABLIER);
        assertEq(targets[3], Constants.SABLIER);
    }

    function _testValues() internal {
        for(uint8 i = 0; i < 4; i++){
            assertEq(values[i], 0);
        }
    }

    function _testSignatures() internal {
        console.log("approve and createstream sigs: ", signatures[0], signatures[2]);
        emit log_named_bytes("encoded approve", abi.encode(signatures[0]));
        assertEq(keccak256(abi.encode(signatures[0])), keccak256(abi.encode("approve(address,uint256)")));
        assertEq(keccak256(abi.encode(signatures[1])), keccak256(abi.encode("approve(address,uint256)")));
        assertEq(keccak256(abi.encode(signatures[2])), 
                keccak256(abi.encode("createStream(address,uint256,address,uint256,uint256)")));
        assertEq(keccak256(abi.encode(signatures[3])), 
                keccak256(abi.encode("createStream(address,uint256,address,uint256,uint256)")));
    }

    function _testCalldatas() internal {
        address target;
        uint256 amount;

        // action 1
        (target, amount) = abi.decode(calldatas[0], (address, uint256));
        assertEq(target, Constants.SABLIER, "target is not sablier");
        assertEq(amount, proposal.amountComp(), "amount of COMP is wrong");

        // action 2
        (target, amount) = abi.decode(calldatas[1], (address, uint256));
        assertEq(target, Constants.SABLIER, "target is not sablier");
        assertEq(amount, proposal.amountUsdc(), "amount of USDC is wrong");

        // action 3

        address recipient;
        address token;
        uint256 startTime;
        uint256 endTime;
        (recipient, amount, token, startTime, endTime) = abi.decode(calldatas[2], 
                                                        (address, uint256, address, uint256, uint256));
        console.log("got for calldata[2]: ", startTime, endTime);

        assertEq(recipient, Constants.CERTORA, "wrong recipient");
        assertEq(amount, proposal.amountComp(), "wrong comp amount");
        assertEq(token, Constants.COMP_TOKEN, "wrong comp token address");

        assertEq(endTime - startTime, 60 * 60 * 24 * 365, "wrong comp stream duration");

        // amount and duration must be divisible without remainder
        assertEq(amount % (endTime - startTime), 0, "comp amount not divisible by duration");

        // startTime must be after current time + 2 weeks
        assertGt(startTime, block.timestamp + Constants.MAX_VOTING_PERIOD * 15 - 1, "comp stream starts too soon");

        // action 4
        (recipient, amount, token, startTime, endTime) = abi.decode(calldatas[3], 
                                                        (address, uint256, address, uint256, uint256));

        assertEq(recipient, Constants.CERTORA, "wrong recipient");
        assertEq(amount, proposal.amountUsdc(), "wrong usdc amount");
        assertEq(token, Constants.USDC_TOKEN, "wrong usdc token address");

        assertEq(endTime - startTime, 60 * 60 * 24 * 365, "wrong usdc stream duration");

        // amount and duration must be divisible without remainder
        assertEq(amount % (endTime - startTime), 0, "usdc amount not divisible by duration");

        // startTime must be after current time + 2 weeks
        assertGt(startTime, block.timestamp +  Constants.MAX_VOTING_PERIOD * 15 - 1, "usdc stream starts too soon");
    }

    function _testDescription() internal {
        assertGt(bytes(description).length, 20);
    }

    function testProposalData() public {
        proposal.buildProposalData();
        bytes memory data = proposal.getProposalData();
        emit log_named_bytes("propose() calldata", data);
        
        (targets, values, signatures, calldatas, description) = abi.decode(data, 
            (address[], uint256[], string[], bytes[], string));

        _testTargets();
        _testValues();
        _testSignatures();
        _testCalldatas();
        _testDescription();
    }
    

    function _testCompToUsdConversion(uint256 compAmount) internal {
        PriceOracle oracle = PriceOracle(Constants.COMP_USD_ORACLE);
        (, int256 compPrice, , , ) = oracle.latestRoundData();
        uint256 givenCompValue = compAmount * uint256(compPrice) / 10 ** oracle.decimals();
        console.log("given Comp Value is:", givenCompValue);
        uint256 expectedUsdValue = Constants.COMP_VALUE * 10 ** (Constants.COMP_DECIMALS);
        console.log("expected Usd value is:", expectedUsdValue);
        
        uint256 margin;
        if (expectedUsdValue > givenCompValue) {
            margin = expectedUsdValue - givenCompValue;
        } else {
            margin = givenCompValue - expectedUsdValue;
        }

        console.log("testing compAmount:", compAmount);
        assertLt(margin, ERROR_MARGIN, "comp value is too far from expected");
    }

    function _testUsdcToUsdConversion() internal {
        uint256 usdcAmount = proposal.convertUSDAmountToUSDC(Constants.USDC_VALUE);
        console.log("usdc amount:", usdcAmount);

        assertEq(usdcAmount, Constants.USDC_VALUE * 10 ** Constants.USDC_DECIMALS);
    }

    function testE2EContract() public {

        IDelegatable comp = IDelegatable(Constants.COMP_TOKEN);
        IGovernorBravo governor = IGovernorBravo(Constants.GOVERNOR_BRAVO);
        uint256 currentBlock = block.number;

        deal(msg.sender, 1e18);
        
        // polychain - 306k votes
        address whale1 = 0xea6C3Db2e7FCA00Ea9d7211a03e83f568Fc13BF7;
        // a16z 256k votes
        address whale2 = 0x9AA835Bc7b8cE13B9B0C9764A52FbF71AC62cCF1;
        // team wallet with 364k tokens
        address whale3 = 0x7587cAefc8096f5F40ACB83A09Df031a018C66ec;

        vm.startPrank(whale3);
        comp.delegate(address(proposal));
        vm.stopPrank();

        uint96 votes = comp.getCurrentVotes(address(proposal));
        assertGt(votes, Constants.MIN_PROPOSAL_THRESHOLD);

        vm.roll(currentBlock + 4 * 60 * 24 * 2);
        vm.warp(block.timestamp + 2 days);
        currentBlock = block.number;

        // run propose()
        uint256 proposalId = proposal.run();

        // proposal _review period is two days in the docs. But it only works with three days.
        vm.roll(currentBlock + 4 * 60 * 24 * 3 + 1);
        vm.warp(block.timestamp + 3 days);
        currentBlock = block.number;

        // vote for proposal
        vm.startPrank(whale1);
        governor.castVote(proposalId, 1);
        vm.stopPrank();

        vm.startPrank(whale2);
        governor.castVote(proposalId, 1);
        vm.stopPrank();

        // proposal voting period
        vm.roll(currentBlock + 4 * 60 * 24 * 3);
        vm.warp(block.timestamp + 3 days);
        currentBlock = block.number;

        // queue
        governor.queue(proposalId);

        // proposal queue time
        vm.roll(currentBlock + 4 * 60 * 24 * 2 + 1);
        vm.warp(block.timestamp + 2 days);
        currentBlock = block.number;

        // execute
        governor.execute(proposalId);

        // check the stream using sablier.nextStreamId()
        uint256 compStreamId = ISablier(Constants.SABLIER).nextStreamId() - 2;
        uint256 usdcStreamId = ISablier(Constants.SABLIER).nextStreamId() - 1;

        _testCompStream(compStreamId);
        _testUsdcStream(usdcStreamId);
    }

    function testE2EProposeCall() public {
        IGovernorBravo governor = IGovernorBravo(Constants.GOVERNOR_BRAVO);
        uint256 currentBlock = block.number;

        deal(msg.sender, 1e18);

        // give enough tokens for a quorum to msg.sender 
        // deal(Constants.COMP_TOKEN, msg.sender, Constants.quorumVotes + 1 );
        // deal doesn't work because it doesn't take into account delegates checkpoints
        
        // polychain - 306k votes
        address whale1 = 0xea6C3Db2e7FCA00Ea9d7211a03e83f568Fc13BF7;
        // a16z 256k votes
        address whale2 = 0x9AA835Bc7b8cE13B9B0C9764A52FbF71AC62cCF1;


        vm.roll(currentBlock + 4 * 60 * 24 * 2);
        vm.warp(block.timestamp + 2 days);
        currentBlock = block.number;

        // run propose()
        proposal.buildProposalData();
        bytes memory proposalData = proposal.getProposalData();
        emit log_named_bytes("proposal data: ", proposalData);
        (targets, values, signatures, calldatas, description) = abi.decode(proposalData, 
            (address[], uint256[], string[], bytes[], string));

        vm.startPrank(whale1);
        uint256 proposalId = governor.propose(targets, values, signatures, calldatas, description);
        console.log("got proposal Id:", proposalId);
        vm.stopPrank();


        // proposal _review period is two days in the docs. But it only works with three days.
        vm.roll(currentBlock + 4 * 60 * 24 * 3 + 1);
        vm.warp(block.timestamp + 3 days);
        currentBlock = block.number;

        // vote for proposal
        vm.startPrank(whale1);
        governor.castVote(proposalId, 1);
        vm.stopPrank();

        vm.startPrank(whale2);
        governor.castVote(proposalId, 1);
        vm.stopPrank();

        // proposal voting period
        vm.roll(currentBlock + 4 * 60 * 24 * 3);
        vm.warp(block.timestamp + 3 days);
        currentBlock = block.number;

        // queue
        governor.queue(proposalId);

        // proposal queue time
        vm.roll(currentBlock + 4 * 60 * 24 * 2 + 1);
        vm.warp(block.timestamp + 2 days);
        currentBlock = block.number;

        // execute
        governor.execute(proposalId);

        // check the stream using sablier.nextStreamId()
        uint256 compStreamId = ISablier(Constants.SABLIER).nextStreamId() - 2;
        uint256 usdcStreamId = ISablier(Constants.SABLIER).nextStreamId() - 1;

        _testCompStream(compStreamId);
        _testUsdcStream(usdcStreamId);
    }

    function _testCompStream(uint256 id) internal {
        address sender;
        address recipient;
        uint256 deposit;
        address token;
        uint256 startTime;
        uint256 stopTime;
        uint256 remainingBalance;
        uint256 ratePerSecond;

        (sender, recipient, deposit, token, startTime, stopTime, remainingBalance, ratePerSecond) = 
            ISablier(Constants.SABLIER).getStream(id);
        
        assertEq(recipient, Constants.CERTORA, "wrong comp stream recipient");
        assertEq(token, Constants.COMP_TOKEN, "wrong comp stream token");
        assertEq(stopTime - startTime, 365 * 24 * 60 * 60, "wrong comp stream duration");
        // starts in the next 7 days
        assertLt(startTime - block.timestamp, 60 * 60 * 24 * 7, "wrong comp stream start time");
        _testCompToUsdConversion(remainingBalance);
    }


    function _testUsdcStream(uint256 id) internal {
        address sender;
        address recipient;
        uint256 deposit;
        address token;
        uint256 startTime;
        uint256 stopTime;
        uint256 remainingBalance;
        uint256 ratePerSecond;

        (sender, recipient, deposit, token, startTime, stopTime, remainingBalance, ratePerSecond) = 
            ISablier(Constants.SABLIER).getStream(id);
        
        assertEq(recipient, Constants.CERTORA, "wrong usdc stream recipient");
        assertEq(token, Constants.USDC_TOKEN, "wrong  usdc  stream token");
        assertEq(stopTime - startTime, 365 * 24 * 60 * 60, "wrong usdc stream duration");

        uint256 expectedUsdc = Constants.USDC_VALUE * 10 ** Constants.USDC_DECIMALS;
        assertLt(expectedUsdc - remainingBalance, ERROR_MARGIN, "wrong usdc stream balance");
        // starts in the next 7 days
        assertLt(startTime - block.timestamp, 60 * 60 * 24 * 7, "wrong usdc stream start time");
    }

}
