<!-- markdownlint-disable -->

# Hardening Report: proudust--gh-describe/v2.2.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **proudust--gh-describe/v2.2.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### broad-permissions (severity: medium)

The workflow sets `permissions: write-all` at the top level, granting overly broad write access to all GitHub API scopes for every job. This should be replaced with specific minimal permissions per job.

Locations:

- `.github/workflows/build.yml:9`

### unpinned-uses (severity: high)

Multiple `uses:` references in build.yml are pinned to mutable version tags rather than immutable full 40-character SHA commit hashes, making the workflow vulnerable to supply-chain attacks if those tags are moved or compromised. Failing references: `actions/checkout@v6` (build, compile, test, release jobs), `actions/setup-node@v6` (build, compile, test jobs), `denoland/setup-deno@v2` (build, compile, test jobs), `actions/upload-artifact@v7` (compile job), `actions/download-artifact@v8` (release job).

Locations:

- `.github/workflows/build.yml:19`
- `.github/workflows/build.yml:22`
- `.github/workflows/build.yml:26`
- `.github/workflows/build.yml:52`
- `.github/workflows/build.yml:55`
- `.github/workflows/build.yml:59`
- `.github/workflows/build.yml:65`
- `.github/workflows/build.yml:80`
- `.github/workflows/build.yml:84`
- `.github/workflows/build.yml:88`
- `.github/workflows/build.yml:158`
- `.github/workflows/build.yml:161`

### script-injection (severity: high)

Sub-rule (a): GitHub Actions expressions are interpolated directly inside `run:` shell command strings. In the 'Check outputs' step, `${{ steps.ghd.outputs.describe }}`, `${{ steps.ghd.outputs.tag }}`, `${{ steps.ghd.outputs.distance }}`, `${{ steps.ghd.outputs.sha }}`, and `${{ steps.ghd.outputs.short-sha }}` are embedded directly in echo commands. In the 'Check all-inputs outputs' step, `${{ steps.ghd_with_all_inputs.outputs.tag }}` and `${{ steps.ghd_with_all_inputs.outputs.distance }}` are embedded in shell comparison expressions (`[[ "${{ ... }}" == "v1.0.0" ]]`). If any step output contains shell metacharacters, this allows command injection. These values should be passed via `env:` variables and referenced as quoted shell variables instead.

Locations:

- `.github/workflows/build.yml:113`
- `.github/workflows/build.yml:135`

## Iteration Notes

### Iteration 1

**Fixes applied:** broad-permissions, unpinned-uses, script-injection

**Notes:**

Fixed all three findings in .github/workflows/build.yml:

1. broad-permissions: Replaced top-level `permissions: write-all` with `permissions: {}` and added minimal per-job permissions: `contents: read` for build/compile/test jobs, `contents: write` for the release job.

2. unpinned-uses: Pinned all 5 action references to full 40-char SHAs: actions/checkout@d23441a48e516b6c34aea4fa41551a30e30af803 (v6), actions/setup-node@249970729cb0ef3589644e2896645e5dc5ba9c38 (v6), denoland/setup-deno@22d081ff2d3a40755e97629de92e3bcbfa7cf2ed (v2), actions/upload-artifact@043fb46d1a93c77aae656e7c1c64a875d1fc6a0a (v7), actions/download-artifact@3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c (v8).

3. script-injection: Moved all ${{ steps.*.outputs.* }} expressions from run: shell strings into env: blocks in both the 'Check outputs' step and the 'Check all-inputs outputs' step. Shell comparison expressions now reference plain env vars ($GHD_ALL_TAG, $GHD_ALL_DISTANCE) instead of ${{ }} interpolations.

