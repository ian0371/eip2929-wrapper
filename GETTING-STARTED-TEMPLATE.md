# Getting Started

## Prerequisites

<_A bash script or a guide to install prerequisites_>

```bash
npm install

# install foundry (https://getfoundry.sh/)
curl -L https://foundry.paradigm.xyz | bash
```

## Quickstart

<_A bash script to go through all the development cycle_>

To Build & Test,

```bash
npx hardhat compile

npx hardhat test
forge test

npx hardhat coverage
forge coverage

# run scripts
forge script script/Counter.s.sol
forge script script/Counter.s.sol --rpc-url baobab
```

To deploy on local network, run `anvil` (or `npx hardhat node`) from another window and then continue.

```bash
# WARNING: this PRIVATE_KEY is well known! do not use for production!
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

npx hardhat deploy --network localhost --reset
npx hardhat call Counter number --network localhost # available via hardhat-utils plugin
npx hardhat run script/counter_inc.ts --network localhost
```

## Guide For Development

<_A detailed guideline for each stage of development cycle_>

### Compile

All contracts in [contracts/](contracts/) directory are compiled.

```bash
forge build
# or
npx hardhat compile
```

### Unit Test

Files in [test/](test/) directory are run.

```bash
forge test
# or
npx hardhat test
```

### Coverage Test

Coverage test is to figure out the coverage of the unit test.

```bash
forge coverage
# or
npx hardhat coverage
```

### Test on Localhost Network

#### Spawning a Localhost Node

There are two types of localhost network:

- ethereum node (anvil from foundry, hardhat-node from hardhat, or ganache from truffle)
- klaytn node (klaytn-deploy or homi).

These networks are defined in `foundry.toml` and `hardhat.config.ts`.

To spawn a localhost network with ethereum node:

```bash
anvil
# or
npx hardhat node
```

To spawn a localhost network with klaytn node: see [here](./KLAYTN-NODE-SETUP.md)

#### Deployment on Localhost

`hardhat-deploy` is a great tool for managing deployments. Note that it will use the output compiled with hardhat.

To run deploy scripts on the localhost network:

```bash
npx hardhat deploy --network localhost
```

It runs scripts in [deploy/](deploy/) directory and saves the result on `deployments/` directory.

Try running the command again. It will reuse the contracts if previous deployments are found.

By default, this runs all scripts in [deploy/](deploy/). To run specific ones, we need to specify "tags" in the deploy script. For example, in case of [deploy/deploy_counter.ts](deploy/deploy_counter.ts):

```
func.tags = ["Counter"];
```

Then run:

```bash
npx hardhat deploy --network localhost --tags Counter
```

[hardhat-utils](https://github.com/klaytn/hardhat-utils) plugin imports symbols from hardhat artifacts for `call` and `send` commands. Check the number variable with:

```bash
npx hardhat call Counter number --network localhost
```

### Script

Both hardhat and foundry provides scripting feature.

#### hardhat scripts

We can use `hardhat-deploy` and `hardhat-ethers` from scripts.

To run the script on the localhost network:

```bash
npx hardhat run script/counter_inc.ts --network localhost
```

#### forge scripts

Foundry supports [local/on-chain simulation modes](https://book.getfoundry.sh/tutorials/solidity-scripting#high-level-overview).
Note that `local` does not mean the localhost network by `anvil` or `npx hardhat node`, but a local EVM simulation.

To run the local simulation:

```bash
forge script script/Counter.s.sol
```

Now, let's run on-chain simulation on forked Baobab. Note that it will create a forked Baobab network locally and run transactions there. In other words, it will not send transactions to Baobab.

To run the on-chain simulation:

```bash
forge script script/Counter.s.sol --rpc-url baobab
```

If all succeeds, you are ready to deploy contracts and send transactions to Baobab.
See operation guide for deployment on Baobab.

### Library functions

Functions that can be reused in tests/scripts need to be in the library.
For example, we can create a function that calls multiple `counter.setNumber(x)` in [lib/hardhat/index.ts](lib/hardhat/index.ts):

```typescript
async function setNumbers(counter: ethers.Contract, numList?: BigInt[]) {
  if (numList === undefined) {
    return;
  }
  for (const num of numList) {
    console.log("========================");
    console.log(`#${num}`);
    console.log("Setting number:", num);
    let tx = await counter.setNumber(num);
    await tx.wait();
    console.log("number set:", await counter.number());
  }
}
```

Then, we can use it from tests/scripts:

```typescript
import { setNumbers } from "../lib";
...
```

### Deployment

You need to create a network label for each deployment purpose.
For example, if we need one for QA on Baobab, append to networks in `hardhat.config.ts`:

```typescript
const config: HardhatUserConfig = {
  // ...
  networks: {
    baobab: {
      /* ... */
    },
    cypress: {
      /* ... */
    },
    "baobab-qa": {
      url: process.env.BAOBAB_URL || "https://archive-en.baobab.klaytn.net",
      accounts: [process.env.PRIVATE_KEY as string],
      live: false,
      saveDeployments: true,
    },
  },
  // ...
};
```

To deploy:

```bash
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
npx hardhat deploy --network baobab-qa --tags Counter
```

To send transactions:

```bash
export COUNTER=$(cat deployments/baobab-qa/Counter.json | jq -r .address)
forge script script/Counter.s.sol --rpc-url baobab-qa --private-key $PRIVATE_KEY --broadcast
# or
npx hardhat run script/counter_inc.ts --network baobab-qa
```

### Verification

Upload the following file to [scope](https://scope.klaytn.com/) or [finder](https://www.klaytnfinder.io/):

```bash
npx hardhat smart-flatten contracts/Counter.sol
cat artifacts/Counter.flat.sol | pbcopy
```

### Publish

By running the following commands, files in `package.json` -> `files` are published.
The published files are:

- `contracts/`
- `dist/lib/` (compile output of `lib/`)
- `dist/export/` (output of `npm run export`)
- `LICENSE`
- `README.md`.

```bash
npm publish
```

After publishing, users can use the library functions as follows:

```typescript
import { setNumbers } from "@klaytn/contract-template";
...
```

See [script/counter_setnums.ts](script/counter_setnums.ts) for details.

## Configuration

This template ships default configurations. However, if you need to change it, here's are some options:

Here are the list of configurable files:

- `package.json`: package info
  - necessary information must be updated by running `npm init` (as in [this section](#must-do-after-repo-creation))
  - others (files, scripts, etc.) can be updated manually
- `hardhat.config.ts` (please sync `foundry.toml` as well)
  - `defaultKey`: default key to be used if `env.PRIVATE_KEY` is empty. Default is the [well known key](https://hardhat.org/hardhat-network/docs/reference#accounts)
  - `network`: list of networks. Can be selected with `npx hardhat --network` flag. These can contain tags depending on the deployment purpose, such as `baobab-qa`
  - `namedAccounts`: accounts for `getNamedAccounts()` (see [deploy/deploy_lock.ts](deploy/deploy_lock.ts))
  - `etherscan`: required for etherscan-verify
  - `dodoc`: required for hardhat-utils
  - `paths`: required for hardhat-deploy
  - `external`: required for hardhat-deploy
- `foundry.toml` (please sync `hardhat.config.ts` as well)
  - `profile`: list of profiles. Can be selected with `HARDHAT_PROFILE` environment variable.
  - `rpc_endpoints`: alias for `cast`
