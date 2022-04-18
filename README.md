# Compound Proposal Implementation

Implementation of this [funding proposal](https://www.comp.xyz/t/certora-formal-verification-proposal/3116).

It can run in two ways:

1. Deploy the `Proposal` contract, then execute the `run()` function.

2. Run the test `forge test -vvvv` and copy the `propose()` calldata from the logs.
   Use the calldata as in input for Compounds Governor Bravo contract's `propose()` function.

## Installation

1. Install [Foundry](https://book.getfoundry.sh/getting-started/installation.html)

2. Run `forge install`

3. Run `forge test -vvvv` for tests.