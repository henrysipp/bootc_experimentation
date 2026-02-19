# Security Review — bootc_experimentation

**Date:** 2026-02-19

## HIGH Severity

### 1. Unpinned GitHub Actions — Supply Chain Risk

Two actions reference `@main` instead of a pinned commit SHA. A compromise of those upstream repos would silently inject malicious code into CI:

- `.github/workflows/build.yml:56` — `ublue-os/container-storage-action@main`
- `.github/workflows/build-disk.yml:82` — `osbuild/bootc-image-builder-action@main`

**Recommendation:** Pin to a specific commit SHA, consistent with how all other actions in the repo are already pinned.

### 2. Script Injection via Direct `${{ }}` Interpolation in Shell

In `.github/workflows/build-disk.yml:115`:

```bash
rclone copy $SOURCE_DIR S3:${{ secrets.S3_BUCKET_NAME }}
```

`${{ }}` expressions are interpolated before bash parses the script. If the value contains shell metacharacters, it becomes command injection. The same pattern appears at line 55 with `${{ matrix.disk-type }}`.

**Recommendation:** Pass all `${{ }}` values through environment variables instead of direct interpolation:

```yaml
env:
  S3_BUCKET: ${{ secrets.S3_BUCKET_NAME }}
run: |
  rclone copy "$SOURCE_DIR" "S3:${S3_BUCKET}"
```

### 3. Container Images Referenced by Mutable Tags

Several images are pulled by tag (not digest), making them vulnerable to tag-mutation attacks:

| File | Line | Image |
|------|------|-------|
| `Containerfile` | 15 | `ghcr.io/ublue-os/bluefin-dx:stable` |
| `Justfile` | 3 | `quay.io/centos-bootc/bootc-image-builder:latest` |
| `Justfile` | 260 | `docker.io/qemux/qemu` (no tag) |
| `build-disk.yml` | 30 | `ghcr.io/lorbuschris/bootc-image-builder:20250608` |

**Recommendation:** Use image digests (`@sha256:...`) in CI workflows.

---

## MEDIUM Severity

### 4. Unquoted Variable Expansions in Justfile

Multiple shell variables are expanded without quotes, risking word splitting and glob expansion:

- Line 144: `TMPDIR=${COPYTMP}` — unquoted
- Line 178: `-v $(pwd)/${config}:/config.toml:ro` — unquoted, path traversal risk
- Line 179: `-v $BUILDTMP:/output` — unquoted
- Line 182: `${args}` — intentional splitting but `$type` comes from user input
- Line 186: `sudo mv -f $BUILDTMP/* output/` — unquoted glob under sudo

**Recommendation:** Quote all variable expansions. Use bash arrays instead of string splitting for `args`.

### 5. Privileged Container with Disabled SELinux

`Justfile:171-177` — bootc-image-builder runs with `--privileged` and `--security-opt label=type:unconfined_t`. This is a known requirement for the tool, but means any vulnerability in the container could compromise the host.

**Recommendation:** Document as a known risk. Only run in isolated/ephemeral environments.

### 6. Third-Party COPR Repository

`build_files/hypr.sh:5` — `dnf5 -y copr enable solopasha/hyprland` adds a user-maintained repository not subject to Fedora package review.

**Recommendation:** Consider mirroring needed packages or pinning to a specific build.

### 7. Disabled Installer Security Modules

`disk_config/iso.toml:12-18` disables Anaconda Security, Network, and Users modules for the ISO installer.

**Recommendation:** Document the rationale for disabling these modules.

---

## LOW Severity

### 8. Commented-Out Insecure SMB Mount

`build_files/build.sh:26` — commented-out SMB mount uses `guest` auth and `0777` permissions.

**Recommendation:** Remove or fix before uncommenting.

### 9. Hardcoded GIDs

`build_files/1password.sh:10-12` — GIDs 1001 and 1019 are hardcoded and may conflict with groups on the base image.

### 10. Temporary Files in Working Directory

`Justfile:143,169` — `mktemp -p "${PWD}"` creates temp dirs visible to other users on shared systems.

---

## Positive Findings

- Secrets properly managed via `${{ secrets.* }}` and `.gitignore`
- Most GitHub Actions pinned to commit SHAs with automated updates
- Cosign image signing implemented
- No hardcoded credentials found
- Build scripts use `set -euo pipefail`
- Multi-stage build avoids leaking build files into final image
