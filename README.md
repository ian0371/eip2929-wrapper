# ERC2929 wrapper

This repo tries to solve out-of-gas

## Deploy

```bash
hh deploy --network baobab --tags Receiver,Entrypoint,Proxy

// update EIP2929Wrapper.sol's variables
// - prefetch: with Proxy address
// - to: with Entrypoint address
hh deploy --network baobab --tags Wrapper

```

- prefetch: address that calls SLOAD

## Run script

```bash
hh run script/run.ts --network baobab

```

## Run script

See SLOAD

```bash
cast rpc debug_traceTransaction 0x5b68d7f64fc942215cd0bbefa2a28e98d632c2091c78f321bd0bc3827b48cebc -r baobab >! trace.json

rg -o -Pe "SLOAD.*?depth" trace.json
# or if you prefer grep,
egrep -o -e "SLOAD.*?depth" trace.json
```
