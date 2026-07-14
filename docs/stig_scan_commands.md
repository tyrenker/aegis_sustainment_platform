# STIG scan commands (scratch notes — delete once memorized)

Run these on the test EC2 (`ssh -i ~/.ssh/aegis-lab.pem ec2-user@<instance-ip>`), not locally.
The benchmark file and `oscap` binary both live on the instance.

## Find your profile ID

You already ran this once:

```bash
oscap info ~/stig_benchmark.xml
```

(This file now shows up automatically at `~/stig_benchmark.xml` on every fresh instance —
Terraform pushes it via a `file` provisioner on `terraform apply`, so the manual `scp` step
is gone.)

Under each `Profile` block, grab the `Id:` value (long, starts with `xccdf_mil.disa.stig_profile_...`),
not the human-readable title. Paste it in place of `<PROFILE_ID>` below.

## Scan command (always all rules)

Always run the full profile, not a single `--rule` — a fix for one finding can regress another
(e.g. an Ansible task that restarts a service can reset a setting elsewhere), so a single-rule
pass doesn't tell you the instance is still compliant overall. The full scan is slower per run
but it's the only result that's actually trustworthy.

```bash
sudo oscap xccdf eval \
  --profile xccdf_mil.disa.stig_profile_MAC-1_Sensitive \
  --results results.xml \
  --report report.html \
  ~/stig_benchmark.xml
```

- `--results` — machine-readable XCCDF results (pass/fail per rule)
- `--report` — the human-readable HTML report you `scp` back and open locally
- exits non-zero if any rule fails — that's expected, not an error in the command itself
- to check progress on one specific finding, `grep` its Rule ID out of `results.xml` rather than
  rerunning with `--rule` — keeps every run testing the whole profile

> **Watch for trailing spaces after `\`.** Bash's line-continuation only works if `\` is the
> very last character on the line — a space after it (easy to introduce via copy/paste) makes
> bash silently end the command there instead of continuing to the next line. Symptom: the next
> line runs as its own (broken) command, e.g. `-bash: --rule: command not found`. Safest fix if
> this happens again: retype the command on one line instead of hunting for the stray space.

## Pull the report back to your laptop

```bash
scp -i ~/.ssh/aegis-lab.pem ec2-user@<instance-ip>:~/report.html .
```

Then open `report.html` locally in a browser.

## Why MAC-1_Sensitive

Highest mission-criticality tier (most rules = more findings to practice remediating), Sensitive
rather than Classified since Aegis doesn't handle actual classified data. Full profile list for
reference (from `oscap info ~/stig_benchmark.xml`):

- `xccdf_mil.disa.stig_profile_MAC-1_Classified`
- `xccdf_mil.disa.stig_profile_MAC-1_Public`
- `xccdf_mil.disa.stig_profile_MAC-1_Sensitive` ← in use
- `xccdf_mil.disa.stig_profile_MAC-2_Classified`
- `xccdf_mil.disa.stig_profile_MAC-2_Public`
- `xccdf_mil.disa.stig_profile_MAC-2_Sensitive`
- `xccdf_mil.disa.stig_profile_MAC-3_Classified`
- `xccdf_mil.disa.stig_profile_MAC-3_Public`
- `xccdf_mil.disa.stig_profile_MAC-3_Sensitive`
- `xccdf_mil.disa.stig_profile_Disable_Slow_Rules`
- `xccdf_mil.disa.stig_profile_CAT_I_Only`