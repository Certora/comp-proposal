// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

library Constants {

    string internal constant DESCRIPTION = "A proposal for significantly and continuously"
    "improving the security of the Compound platform and the dApps built on top of it, by offering" 
    "our formal verification and path coverage tooling service to the Compound Platform contributors" 
    "and the Compound Protocol dApp developers. This is a follow-up to our recent work on the Comet "
    "protocol with the Compound labs team. The idea is to provide access to the community and educate" 
    "the community, write formal specifications, and review code changes. This proposal is orthogonal "
    "to the Open Zeppelin proposal, which has already been suggested using the Certora prover. "
    "This proposal also suggests writing formal correctness rules for the Compound Protocol which"
    " will be reviewed by the community and OpenZeppelin. We have already written some formal "
    "requirements for Comet and prevented huge security breaches."
    "This is an update of an earlier unsubmitted proposal 2 discussed in November 2021.";

    address internal constant COMP_TOKEN = 0xc00e94Cb662C3520282E6f5717214004A7f26888;
    address internal constant GOVERNOR_BRAVO = 0xc0Da02939E1441F497fd74F78cE7Decb17B66529;
    address internal constant TIMELOCK = 0x6d903f6003cca6255D85CcA4D3B5E5146dC33925;

    address internal constant USDC_TOKEN = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address internal constant SABLIER = 0xCD18eAa163733Da39c232722cBC4E8940b1D8888;

    address internal constant CERTORA = 0x0F11640BF66e2D9352d9c41434A5C6E597c5e4c8;

    // $1M allocation of COMP
    uint256 internal constant COMP_VALUE = 1000000;
    uint256 internal constant USDC_VALUE = 1000000;

    uint256 internal constant COMP_DECIMALS = 18;
    uint256 internal constant USDC_DECIMALS = 6;

    address internal constant COMP_USD_ORACLE = 0xdbd020CAeF83eFd542f4De03e3cF0C28A4428bd5;

    uint256 public constant GRACE_PERIOD = 60 * 60 * 24; // 1 day additional grace period

    // These constants are from Compound's GovernorBravoDelegate contract
    // https://github.com/compound-finance/compound-protocol/blob/master/contracts/Governance/GovernorBravoDelegateG2.sol

    /// @notice The minimum setable proposal threshold
    uint public constant MIN_PROPOSAL_THRESHOLD = 50000e18; // 50,000 Comp

    /// @notice The maximum setable proposal threshold
    uint public constant MAX_PROPOSAL_THRESHOLD = 100000e18; //100,000 Comp

    /// @notice The minimum setable voting period
    uint public constant MIN_VOTING_PERIOD = 5760; // About 24 hours

    /// @notice The max setable voting period
    uint public constant MAX_VOTING_PERIOD = 80640; // About 2 weeks

    /// @notice The min setable voting delay
    uint public constant MIN_VOTING_DELAY = 1;

    /// @notice The max setable voting delay
    uint public constant MAX_VOTING_DELAY = 40320; // About 1 week

    /// @notice The number of votes in support of a proposal required in order for a quorum to be reached and for a vote to succeed
    uint public constant quorumVotes = 400000e18; // 400,000 = 4% of Comp

    uint public constant  TIMELOCK_DELAY = 172800; // seconds

}