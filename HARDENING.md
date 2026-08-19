<!-- markdownlint-disable -->

# Hardening Report: proudust--gh-describe/v2.1.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **proudust--gh-describe/v2.1.1** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

All `uses:` references in .github/workflows/build.yml are pinned to mutable version tags rather than full 40-character commit SHAs. This exposes the workflow to supply-chain attacks if any referenced action is compromised or its tag is moved. Failing references include: actions/checkout@v5, actions/setup-node@v6, denoland/setup-deno@v2, actions/upload-artifact@v4, actions/download-artifact@v5. Each should be pinned to a full SHA (e.g. `actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v5`).

Locations:

- `.github/workflows/build.yml:17`
- `.github/workflows/build.yml:20`
- `.github/workflows/build.yml:24`
- `.github/workflows/build.yml:47`
- `.github/workflows/build.yml:50`
- `.github/workflows/build.yml:54`
- `.github/workflows/build.yml:60`
- `.github/workflows/build.yml:68`
- `.github/workflows/build.yml:71`
- `.github/workflows/build.yml:75`
- `.github/workflows/build.yml:113`
- `.github/workflows/build.yml:130`

### broad-permissions (severity: medium)

The workflow file .github/workflows/build.yml sets `permissions: write-all` at the top level, granting every job in the workflow write access to all available GitHub API scopes. This violates the principle of least privilege. Replace with specific minimal permissions (e.g. `contents: write` only for the release job, and `contents: read` for others).

Locations:

- `.github/workflows/build.yml:9`

### script-injection (severity: high)

Sub-rule (a): The 'Check outputs' step directly interpolates `${{ steps.ghd.outputs.* }}` expressions inside a `run:` shell block. The `steps.*.outputs.*` context is workflow-controllable — its values flow through YAML template substitution before the shell processes them, allowing an attacker to inject shell metacharacters. Offending lines:
  echo "describe  : ${{ steps.ghd.outputs.describe }}"
  echo "tag       : ${{ steps.ghd.outputs.tag }}"
  echo "distance  : ${{ steps.ghd.outputs.distance }}"
  echo "sha       : ${{ steps.ghd.outputs.sha }}"
  echo "short-sha : ${{ steps.ghd.outputs.short-sha }}"
Fix: move each value into an `env:` block and reference the env var (double-quoted) inside the run script.

Locations:

- `.github/workflows/build.yml:115`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, broad-permissions, script-injection

**Notes:**

Fixed all three findings in .github/workflows/build.yml:
1. unpinned-uses: Pinned all 5 actions to full SHAs with tag comments — actions/checkout@fbc6f3992d24b796d5a048ff273f7fcc4a7b6c09 # v5, actions/setup-node@249970729cb0ef3589644e2896645e5dc5ba9c38 # v6, denoland/setup-deno@22d081ff2d3a40755e97629de92e3bcbfa7cf2ed # v2, actions/upload-artifact@ea165f8d65b6e75b540449e92b4886f43607fa02 # v4, actions/download-artifact@634f93cb2916e3fdff6788551b99b062d0335ce0 # v5.
2. broad-permissions: Replaced top-level `permissions: write-all` with `permissions: {}` and added per-job minimal permissions: `contents: read` for build/compile/test jobs, `contents: write` for the release job.
3. script-injection: Moved all `${{ steps.ghd.outputs.* }}` expressions in the 'Check outputs' step into an `env:` block (GHD_DESCRIBE, GHD_TAG, GHD_DISTANCE, GHD_SHA, GHD_SHORT_SHA) and referenced them as plain env vars in the shell script.

