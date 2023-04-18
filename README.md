# ERC2929 wrapper

This repo is to solve out-of-gas problems caused by executing `transfer()` followed by `SLOAD` opcode.

## Motivation

As per [EIP-2929](https://eips.ethereum.org/EIPS/eip-2929), the gas cost of `SLOAD` opcode when it is first invoked increases.

In Klaytn, `SLOAD` uses 2100 gas (ref: [link](https://github.com/klaytn/klaytn/blob/357b136dc832be81800e0f75f2e9d600938c66f5/params/protocol_params.go#L56)).

However, `transfer()` stipends only 2300 gas (ref: [link](https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/)).

This can cause out-of-gas problems after kore hardfork where EIP-2929 was introduced.

## Solution

The solution this repo suggests is to create a "wrapper" contract to execute `SLOAD` first so that later `SLOAD`s cost less.

# Demo

## Prerequisites

- `npm i`

Deploy contracts:

```bash
hh deploy --network baobab
```

Run the failure script. This _will revert_:

```bash
hh run script/run-fail.ts --network baobab
```

You can see [a sample tx](https://baobab.scope.klaytn.com/tx/0xc51b18d73a448ed80c6f0fdad9e38afcb3c5383e92cd1df90da1d9ab20e64aa5?tabId=internalTx).

Now, run the success script. This _will not revert_:

```bash
hh run script/run.ts --network baobab
```

You can see [a sample tx](https://baobab.scope.klaytn.com/tx/0x985e26d9bbbe5dd3ed55b6c7e0b4e7eb50b939ce3cdae8a47c418190a0356f1f?tabId=internalTx).

If we run debug.traceTransaction on above txs, we can see the difference:

Failing run:

```
"op":"SLOAD","gas":9978483,"gasCost":2100,"depth":...
"op":"SLOAD","gas":2225,"gasCost":2100,"depth":...
```

Successful run:

```
"op":"SLOAD","gas":9816835,"gasCost":2100,"depth":...
"op":"SLOAD","gas":2225,"gasCost":100,"depth":...
```

#

The solution this repo suggests is to create a "wrapper" contract to execute `SLOAD` first so that later `SLOAD`s cost less.
