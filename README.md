# Contract-template

```
hh deploy --network baobab --tags Receiver,Entrypoint,Proxy

// update EIP2929Wrapper.sol's variables
// - prefetch: with Proxy address
// - to: with Entrypoint address
hh deploy --network baobab --tags Wrapper


hh run script/run.ts --network baobab
```
