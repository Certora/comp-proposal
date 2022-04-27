using FiatTokenV2_1 as usdc
using Comp as comp
using ChainlinkHarness as oracle

methods {
    convertUSDAmountToComp(uint256 usdAmount) returns uint256
    convertUSDAmountToUSDC(uint256 usdAmount) returns uint256
    decimals() returns uint8 => DISPATCHER(true)
    usdc.decimals() returns uint8 envfree
    comp.decimals() returns uint8 envfree
    oracle.decimals() returns uint8 envfree
}

function oracleAssumptions() {
    require oracle.decimals() <= 27;
}

// rule sanity(method f) {
//     oracleAssumptions();
//     env e;
//     calldataarg arg;
//     f(e,arg);
//     assert false;
// }

rule compConversionAdditive(uint amt1, uint amt2) {
    oracleAssumptions();
    env e;
    require amt1 + amt2 <= max_uint256;
    require comp.decimals() == 18;
    mathint sumOfConversions = convertUSDAmountToComp(e, amt1) + convertUSDAmountToComp(e, amt2);
    mathint conversionOfSum = convertUSDAmountToComp(e, amt1 + amt2);
    uint delta = 1;
    assert sumOfConversions - delta <= conversionOfSum && conversionOfSum <= sumOfConversions + delta;
} 

rule compConversionAdditivePrecise(uint amt1, uint amt2) {
    oracleAssumptions();
    env e;
    require amt1 + amt2 <= max_uint256;
    require comp.decimals() == 18;
    uint sumOfConversions = convertUSDAmountToComp(e, amt1) + convertUSDAmountToComp(e, amt2);
    uint conversionOfSum = convertUSDAmountToComp(e, amt1 + amt2);
    assert sumOfConversions == conversionOfSum;
} 

rule usdcConversionAdditive(uint amt1, uint amt2) {
    oracleAssumptions();
    env e;
    require amt1 + amt2 <= max_uint256;
    require usdc.decimals() == 18;
    uint sumOfConversions = convertUSDAmountToUSDC(e, amt1) + convertUSDAmountToUSDC(e, amt2);
    uint conversionOfSum = convertUSDAmountToUSDC(e, amt1 + amt2);
    uint delta = 1;
    assert sumOfConversions - delta <= conversionOfSum && conversionOfSum <= sumOfConversions + delta;
} 

rule usdcConversionAdditivePrecise(uint amt1, uint amt2) {
    oracleAssumptions();
    env e;
    require amt1 + amt2 <= max_uint256;
    require usdc.decimals() == 18;
    uint sumOfConversions = convertUSDAmountToUSDC(e, amt1) + convertUSDAmountToUSDC(e, amt2);
    uint conversionOfSum = convertUSDAmountToUSDC(e, amt1 + amt2);
    assert sumOfConversions == conversionOfSum;
} 