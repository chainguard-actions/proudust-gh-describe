<!-- markdownlint-disable -->

# Hardening Report: proudust--gh-describe/v2.1.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **proudust--gh-describe/v2.1.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### broad-permissions (severity: medium)

The workflow sets `permissions: write-all` at the top level, granting overly broad write access to all GitHub API scopes for every job. This should be replaced with specific minimal permissions per job.

Locations:

- `.github/workflows/build.yml:9`

### unpinned-uses (severity: high)

All `uses:` references in the workflow use mutable version tags instead of pinned 40-character SHA digests, making the workflow vulnerable to supply-chain attacks if any referenced action is compromised or its tag is moved. Failing references: `actions/checkout@v4` (lines 19, 52, 80, 138), `actions/setup-node@v4` (lines 22, 55, 83), `denoland/setup-deno@v1` (lines 26, 59, 87), `actions/upload-artifact@v4` (line 65), `actions/download-artifact@v4` (line 141).

Locations:

- `.github/workflows/build.yml:19`
- `.github/workflows/build.yml:22`
- `.github/workflows/build.yml:26`
- `.github/workflows/build.yml:52`
- `.github/workflows/build.yml:55`
- `.github/workflows/build.yml:59`
- `.github/workflows/build.yml:65`
- `.github/workflows/build.yml:80`
- `.github/workflows/build.yml:83`
- `.github/workflows/build.yml:87`
- `.github/workflows/build.yml:138`
- `.github/workflows/build.yml:141`

### script-injection (severity: high)

Rule (a) violation: The 'Check outputs' step directly interpolates `${{ steps.ghd.outputs.* }}` expressions inside a `run:` shell command string. These values flow through YAML template substitution before the shell sees them, allowing an attacker who can influence the action's outputs to inject arbitrary shell commands. Offending lines: `echo "describe  : ${{ steps.ghd.outputs.describe }}"`, `echo "tag       : ${{ steps.ghd.outputs.tag }}"`, `echo "distance  : ${{ steps.ghd.outputs.distance }}"`, `echo "sha       : ${{ steps.ghd.outputs.sha }}"`, `echo "short-sha : ${{ steps.ghd.outputs.short-sha }}"`.

Locations:

- `.github/workflows/build.yml:120`
- `.github/workflows/build.yml:121`
- `.github/workflows/build.yml:122`
- `.github/workflows/build.yml:123`
- `.github/workflows/build.yml:124`

## Iteration Notes

### Iteration 1

**Fixes applied:** broad-permissions, unpinned-uses, script-injection

**Notes:**

Fixed all three findings in .github/workflows/build.yml:
1. broad-permissions: Replaced top-level `permissions: write-all` with `permissions: {}` and added minimal per-job permissions blocks (contents: read for build/compile/test jobs; contents: write for the release job which needs to create/upload GitHub releases).
2. unpinned-uses: Pinned all 12 uses: references to full 40-char SHAs with tag comments — actions/checkout@v4 → 11d5960a326750d5838078e36cf38b85af677262, actions/setup-node@v4 → 49933ea5288caeca8642d1e84afbd3f7d6820020, denoland/setup-deno@v1 → 11b63cf76cfcafb4e43f97b6cad24d8e8438f62d, actions/upload-artifact@v4 → ea165f8d65b6e75b540449e92b4886f43607fa02, actions/download-artifact@v4 → d3f86a106a0bac45b974a628896c90dbdf5c8093.
3. script-injection: Moved all ${{ steps.ghd.outputs.* }} expressions in the 'Check outputs' step into the step's env: block as GHD_DESCRIBE, GHD_TAG, GHD_DISTANCE, GHD_SHA, GHD_SHORT_SHA, and updated the run: script to reference plain shell variables instead.

