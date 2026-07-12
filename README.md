# Aegis Sustainment Platform (ASP)

A hardened AWS/Kubernetes platform I designed and am building for a fictional Army sustainment
command — the logistics/equipment-maintenance side of military operations, not combat systems.
The project is modeled directly on a real Cloud/Kubernetes Security Engineer job posting at a DoD
contractor, so it's built around the same stack that role actually uses: AWS, Kubernetes, GitOps,
CI/CD, and Zero Trust, all implemented against real DoD compliance standards (STIG, NIST 800-171,
CMMC) rather than a generic tutorial setup. It also includes a self-hosted AI assistant that I red
team myself, since securing AI-integrated systems is a security discipline traditional
infrastructure controls don't cover.

**Status: in progress.** The checklist below reflects real progress, not planned progress — if a
phase is unchecked, it isn't built yet.

## What this demonstrates

- **AWS foundations** — VPC/subnet design, least-privilege IAM (with tested, not assumed,
  boundaries), and a NIST SP 800-171 control mapping tying specific infrastructure to specific
  compliance requirements.
- **Infrastructure as Code** — the entire environment is defined in Terraform, reviewed via
  `plan`/`apply`, not built by hand in the console.
- **DISA STIG compliance-as-code** — a RHEL 9 image hardened against the real DISA STIG, baked
  into an AMI with Packer + Ansible so every new node boots already compliant, verified with
  before/after OpenSCAP scans rather than a claimed compliance percentage.
- **Kubernetes hardening** — an EKS cluster passing CIS Kubernetes Benchmark checks, with
  hand-written OPA/Gatekeeper admission policies (not an imported policy bundle) and Falco runtime
  detection.
- **GitOps** — ArgoCD continuously reconciling the live cluster against a Git repo as the single
  source of truth, with drift automatically detected and reverted.
- **DevSecOps CI/CD** — a GitHub Actions pipeline enforcing three independent security gates
  (Terraform/IaC scanning, container image scanning, policy testing) before anything can merge.
- **Zero Trust identity** — SPIFFE/SPIRE issuing cryptographic workload identities so services
  authenticate each other over mTLS, instead of trusting traffic based on network location.
- **AI system security** — a self-hosted RAG assistant (plus a secondary AWS Bedrock integration),
  red-teamed against my own planted indirect prompt injection attack, mapped to MITRE ATLAS and the
  OWASP LLM Top 10, with tested mitigations.

## How this was built

Written by hand, following `aegis_sustainment_platform_capstone.md` in this repo — a full teaching
doc I use as the reference for every concept and the reasoning behind every step, not a
copy-paste source. A separate AI-generated reference implementation exists at `../aegis-reference/`
for comparison only, consulted after I've already written and tested my own version of a given
piece — never before.

## Status

- [X] Phase 0 — Tooling & AWS account setup
- [X] Phase 1 — Foundation: VPC, IAM, NIST control mapping
- [ ] Phase 2 — STIG-hardened AMI (Packer + Ansible) — *in progress*
- [ ] Phase 3 — EKS cluster, CIS hardening, Gatekeeper policies
- [ ] Phase 4 — GitOps (ArgoCD)
- [ ] Phase 5 — CI/CD DevSecOps gates
- [ ] Phase 6 — Zero Trust identity (SPIRE)
- [ ] Phase 7 — AI assistant (self-hosted RAG + Bedrock)
- [ ] Phase 8 — Full compliance/monitoring pass
- [ ] Phase 9 — AI red team + detection engineering
- [ ] Phase 10 — Full-stack break-it validation
- [ ] Phase 11 — Architecture write-up

## Repo layout

| Path | Phase | What goes here |
|---|---|---|
| `terraform/` | 1, 3 | VPC, IAM, EKS cluster |
| `packer/`, `ansible/` | 2 | STIG-hardened AMI build |
| `k8s/` | 3, 4, 6 | Workload manifests, Gatekeeper policies, ArgoCD app, SPIRE config |
| `policy/` | 5 | Conftest CI policies (mirrors `k8s/gatekeeper/` at a different enforcement point) |
| `.github/workflows/` | 5 | CI/CD pipeline |
| `ai-assistant/` | 7, 9 | RAG assistant, Bedrock call, red-team mitigations |
| `docs/` | 1, 8, 9, 11 | Control mapping, compliance scorer, red-team log, write-up |

Every file with a `# TODO (Phase N, step X): ...` comment is something I write myself — that's
where the actual learning happens. Files without TODOs (e.g., the Terraform provider block, the
Packer wrapper, the ArgoCD Application shape) are boilerplate the reference doc already identifies
as fine to use as-is.
