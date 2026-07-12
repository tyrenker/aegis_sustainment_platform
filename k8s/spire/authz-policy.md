# SPIRE authorization policy — Phase 6, step 5

TODO: write the policy that allows only `comms -> inventory`, and document it here:

- Which SPIFFE ID is allowed to call which SPIFFE ID, and how that's enforced (mTLS + your
  authorization config, not just "they're in the same cluster").
- The test you ran: stand up a third, unregistered mock service, attempt to call `inventory` from
  it, confirm it's rejected. Paste the actual rejection here along with your explanation of the
  exact mechanism (missing/invalid SVID) that caused it.

## Understanding checkpoint (answer this yourself before moving to Phase 7)

Why is "this request came from inside our cluster" a weaker guarantee than "this request came
from a workload that just proved a cryptographic identity to us"? Which DoD Zero Trust pillar does
this phase demonstrate?
