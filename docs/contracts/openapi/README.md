# Mobile-owned Backend OpenAPI Snapshot

`backend.openapi.yaml` is the contract artifact consumed by mobile agents and
CI. `backend.openapi.lock.json` binds it to a SHA-256 digest and the reviewed
backend Git revision without depending on an absolute sibling checkout.

Verify from any clean clone:

```bash
dart run mobile_core_kit_cli:mobilekit contract openapi verify
```

Sync only after backend acceptance, using the explicit procedure in
`docs/engineering/behavioral_oracles.md`. Mobile owns review of the snapshot
delta; backend owns the source contract and compatibility decision.
