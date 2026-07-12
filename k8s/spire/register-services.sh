#!/usr/bin/env bash
# TODO (Phase 6, step 2): register your inventory/comms/ai-assistant workloads with SPIRE.
#
# Before running any of this, read SPIRE's attestation docs enough to explain WHY SPIRE trusts a
# given pod is who it claims to be (it attests Kubernetes-specific properties like namespace +
# service account) — don't just copy commands without understanding what "attestation" is doing.
#
# Shape of a registration entry (repeat per service, with your own SPIFFE IDs/selectors):
#
# kubectl exec -n spire spire-server-0 -- \
#   /opt/spire/bin/spire-server entry create \
#   -spiffeID spiffe://aegis.local/TODO-service-name \
#   -parentID spiffe://aegis.local/agent \
#   -selector k8s:ns:TODO-namespace -selector k8s:sa:TODO-service-account
#
# After registering, use the SPIRE CLI yourself to inspect the issued identity rather than
# assuming it worked:
#   kubectl exec -n spire spire-server-0 -- /opt/spire/bin/spire-server entry show
