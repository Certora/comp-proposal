# Compound Proposal Implementation

Implementation of this [funding proposal](https://www.comp.xyz/t/certora-formal-verification-proposal/3116).

It can run in two ways:

1. Deploy the `Proposal` contract, then execute the `run()` function. The proposal contract must have a
   a delegation of at least 25000 COMP voting power.

2. Run the test `forge test -vvvv -m E2EProposeCall` and copy the `propose()` calldata from the logs.
   Use the calldata as in input for Compounds Governor Bravo contract's `propose()` function.
   The wallet that runs the proposal must have a delegation of at least 25000 COMP voting power.


## Installation

1. Install [Foundry](https://book.getfoundry.sh/getting-started/installation.html)

2. Run `forge install`

3. Run `forge test -vvvv` for tests.

## Testing

`forge test -vvvv -m E2EContract` to test the contract deploy and call path

`forge test -vvvv -m E2EProposeCall` to test the calldata calculation and utilization path.