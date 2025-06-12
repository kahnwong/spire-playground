# spire-playground

Ref: <https://spiffe.io/docs/latest/try/getting-started-k8s/>

Spiffe is a specs, spire is one of spiffe implementations.

----

If you deploy workloads outside of registration parameters (see `manifests/07-*.yaml`, spire-agent would not be able to obtain identity. This means you can add spire-agent as init-container for zero-trust, once init is done workloads can run normally.
