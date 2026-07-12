# TODO (Phase 5, step 3): conftest version of your Gatekeeper "no privileged pods" policy.
#
# This is deliberately a second, independent enforcement point for the same rule as
# k8s/gatekeeper/no-privileged-pods.yaml — one at CI time (catches it before merge), one at live
# cluster admission (catches it if something bypasses CI). Write this one from scratch; don't
# just copy the Gatekeeper Rego, conftest's input shape is different (it evaluates the raw
# manifest, not an AdmissionReview object).
#
# Reference: www.conftest.dev/ and open-policy-agent.github.io/gatekeeper (for the Rego you
# already wrote in k8s/gatekeeper/)

package main

deny[msg] {
	# write your rule here
	msg := "TODO"
}
