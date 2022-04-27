certoraRun src/Proposal.sol src/imports/FiatTokenV2_1.sol src/imports/Comp.sol src/spec/ChainlinkHarness.sol \
    --verify Proposal:src/spec/proposal.spec \
    --solc_map Proposal=solc8.10,Comp=solc5.16,FiatTokenV2_1=solc6.12,ChainlinkHarness=solc8.12 \
    --address Comp:0xc00e94Cb662C3520282E6f5717214004A7f26888 FiatTokenV2_1:0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 ChainlinkHarness:0xdbd020CAeF83eFd542f4De03e3cF0C28A4428bd5 \
    --rule_sanity --cloud