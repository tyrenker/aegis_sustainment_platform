# NIST SP 800-171 Control Mapping — Phase 1

Control ID and Family are picked; the AWS mapping column is filled in as a starting reference.
**The "your words" column is still yours to write** — that's the actual checkpoint. Fill it in
before you write the Terraform for that row, not after, so you're designing against the
requirement instead of retrofitting a justification to whatever you already built.

Rev 2 numbering used below (`3.1.4` style) since that's what current DFARS clauses typically
cite — if your source doc is Rev 3, the same control appears as `03.01.04` style; keep one
convention consistent throughout this table.

| Control ID | Family | What it actually requires (your words) | What in this project satisfies it |
|---|---|---|---|
| 3.1.1 | AC | Requires separation of duties between operators and auditors and prevents unauthorized access to CUI. | `terraform/iam.tf` — separate operator and auditor IAM roles; no anonymous/unauthenticated access to the EKS API (private endpoint access only) |
| 3.1.2 | AC | It requires concept of least privilege | IAM policy actions scoped per role in `terraform/iam.tf` — e.g., the auditor role can only call read-only actions, never anything that mutates state |
| 3.1.4 | AC | Requires controls to prevent unauthorized users from modifying or destroying CUI. | Separate operator vs. auditor IAM roles (`terraform/iam.tf`) — the identity that can change infrastructure isn't the same one reviewing it |
| 3.1.5 | AC | It requires concept of least privilege | Least-privilege IAM policies in `terraform/iam.tf` — no wildcard `Action`/`Resource`, each role scoped to exactly what it needs |
| 3.1.20 | AC | Requires controls to prevent unauthorized users from accessing, modifying, or using CUI in system connected to the internet. | Security groups + NAT gateway controlling all egress (`terraform/vpc.tf`); EKS API server access restricted to private endpoint only |
| 3.3.1 | AU | It requires monitoring of the systems and the security of the information systems. | AWS CloudTrail enabled account-wide (Phase 9) — logs every API call across the environment |
| 3.3.2 | AU | It requires that the activity is tied to an indiviudal user. | CloudTrail logs are tied to individual IAM identities (no shared/root credentials); SPIRE SVIDs (Phase 6) uniquely identify each workload's calls, not just "traffic from the cluster" |
| 3.3.4 | AU | It requires that the system monitors the success of system audtits | CloudWatch alarm on CloudTrail log delivery failure / AWS Config recorder stopping (Phase 9) |
| 3.3.5 | AU | It requires that system monitors the security of the systems | GuardDuty + Security Hub aggregating findings into one reviewable place (Phase 9) rather than checking each log source separately |
| 3.4.1 | CM | The system uses formal controls and configuration baselines to manage system configuration and changes. | The Terraform state + version-controlled `.tf` files themselves are the baseline configuration; the STIG-hardened AMI (Phase 2) is the node-level baseline |
| 3.4.2 | CM | It requires the system organization to implement controls to prevent the installation of unauthorized software | Ansible STIG remediation baked into the AMI (Phase 2) + Gatekeeper admission policies enforcing settings at the Kubernetes layer (Phase 3) |
| 3.4.6 | CM | It requires that the systems are protected from the introduction of malware or unneccessary software. | Unused/legacy services disabled in `ansible/stig-remediation.yml`; minimal container base images in `ai-assistant/Dockerfile` |
| 3.4.7 | CM | It requires that the systems protect against malware and system failures | Security group rules restricting ports to only what's needed (`terraform/vpc.tf`, e.g. 443 only for the cluster SG); Falco (Phase 3) alerting on unexpected process execution at runtime |
| 3.13.1 | SC | It requires that the network is protected from the internet | VPC boundary + NAT gateway + security groups controlling all ingress/egress (`terraform/vpc.tf`) |
| 3.13.5 | SC | It requires the network be isolated from the internet | Public/private subnet split in `terraform/vpc.tf` — nothing except the NAT gateway's EIP is actually internet-facing |
| 3.13.8 | SC | It requires that communications are encrypted and authenticated. | SPIRE-issued SVIDs + mTLS between `inventory` and `comms` (Phase 6) — encrypts and authenticates traffic in transit between services |

## Understanding checkpoint

For 3 of your chosen controls, be ready to explain exactly which piece of AWS configuration
satisfies each one and why — not "IAM handles access control" in general, but the specific
policy/setting.

| 3.1.5 | AC - In IAM.tf file I define IAM policies and roles for each service so that they only have access to the resources they need to complete their job.

| 3.1.1 | AC - IAM.tf file defines separate operator and auditor IAM roles; no anonymous/unauthenticated access to the EKS API (private endpoint access only)

| 3.1.2 | AC | IAM.tf file defines least privilege IAM policies and roles for each service so that they only have access to the resources they need to complete their job.


