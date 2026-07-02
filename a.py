#!/usr/bin/env python3

import pathlib
import subprocess
import sys

PATCH_NAME = "android-rbe-buildbuddyfix-defaults.patch"

REPLACEMENTS = {
    "build/make/core/rbe.mk": [
        (
            "rbe_dir := prebuilts/remoteexecution-client/live/",
            "rbe_dir := prebuilts/remoteexecution-client/buildbuddyfix/",
        ),
        (
            "RBE_WRAPPER := $(rbe_dir)/rewrapper",
            "# Some remote executors reject actions with working_directory=\".\".\n"
            "# Canonicalizing the working dir helps once the client itself is patched.\n"
            "  RBE_WRAPPER := $(rbe_dir)/rewrapper -canonicalize_working_dir",
        ),
    ],

    "build/soong/remoteexec/remoteexec.go": [
        (
            "prebuilts/remoteexecution-client/live/rewrapper",
            "prebuilts/remoteexecution-client/buildbuddyfix/rewrapper",
        ),
    ],

    "build/soong/remoteexec/remoteexec_test.go": [
        (
            "prebuilts/remoteexecution-client/live/rewrapper",
            "prebuilts/remoteexecution-client/buildbuddyfix/rewrapper",
        ),
    ],

    "build/soong/android/config.go": [
        (
            'return c.GetenvWithDefault("RBE_WRAPPER", remoteexec.DefaultWrapperPath)',
            'return c.GetenvWithDefault("RBE_WRAPPER", remoteexec.DefaultWrapperPath+" -canonicalize_working_dir")',
        ),
    ],

    "build/soong/ui/build/config.go": [
        (
            'return "prebuilts/remoteexecution-client/live/"',
            'return "prebuilts/remoteexecution-client/buildbuddyfix/"',
        ),
    ],

    "build/make/rbesetup.sh": [
        (
            'local RBE_BINARIES_DIR="prebuilts/remoteexecution-client/latest"',
            'local RBE_BINARIES_DIR="prebuilts/remoteexecution-client/buildbuddyfix"',
        ),
    ],

    "build/soong/docs/rbe.json": [
        (
            '"RBE_DIR": "prebuilts/remoteexecution-client/live"',
            '"RBE_DIR": "prebuilts/remoteexecution-client/buildbuddyfix"',
        ),
    ],
}


def patch_file(path, changes):
    p = pathlib.Path(path)

    if not p.exists():
        print(f"[ERROR] Missing file: {path}")
        return False

    text = p.read_text(encoding="utf-8")
    original = text

    for old, new in changes:
        if old not in text:
            print(f"[ERROR] Pattern not found in {path}")
            print(f"Missing:\n{old}\n")
            return False
        text = text.replace(old, new, 1)

    if text != original:
        p.write_text(text, encoding="utf-8")
        print(f"[OK] {path}")

    return True


def main():
    try:
        subprocess.run(
            ["git", "rev-parse", "--is-inside-work-tree"],
            check=True,
            stdout=subprocess.DEVNULL,
        )
    except subprocess.CalledProcessError:
        print("Run this from inside a git repository.")
        sys.exit(1)

    for file, changes in REPLACEMENTS.items():
        if not patch_file(file, changes):
            sys.exit(1)

    with open(PATCH_NAME, "w") as f:
        subprocess.run(["git", "diff"], stdout=f, check=True)

    print(f"\nGenerated: {PATCH_NAME}")


if __name__ == "__main__":
    main()