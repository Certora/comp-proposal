## Parameter calculations

Recipient - Certora:
0x0F11640BF66e2D9352d9c41434A5C6E597c5e4c8

Price: 44.85 (Binance MA25 - average over last 25 days taken from binance)

Tokens: $750000 (funding amount) / $44.85 (token price) = 16722.408
Tokens with decimals: 16722408000000000000000

COMP Token address:
0xc00e94Cb662C3520282E6f5717214004A7f26888

Start stream
1649137189 (April 5 - 10 days after proposal posting, 3 day buffer)

End stream (6 months)
1664948389 (October 5)

delta (stream duration): 15811200

Adjusted number of tokens so it divides without remainder by delta:
16722407999999999750400

## Final parameters

COMP.approve("0xCD18eAa163733Da39c232722cBC4E8940b1D8888", 16722407999999999750400)

0xCD18eAa163733Da39c232722cBC4E8940b1D8888.createStream("0x0F11640BF66e2D9352d9c41434A5C6E597c5e4c8", 16722407999999999750400, "COMP", 1649137189, 1664948389)