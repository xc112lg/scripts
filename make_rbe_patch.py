#!/usr/bin/env python3
"""
make_rbe_patch.py

Recreates (or customizes) an AOSP RBE-defaults patch like
android-rbe-buildbuddyfix-defaults.patch.

What it does:
  1. Walks a set of known files in build/make and build/soong that hardcode
     the RBE client directory (default: prebuilts/remoteexecution-client/live
     or /latest) and the rewrapper invocation.
  2. Replaces the old directory name with a new one you choose.
  3. Optionally appends an extra flag (e.g. -canonicalize_working_dir) to the
     rewrapper default invocations.
  4. Runs `git diff` in each affected repo (build/make and build/soong are
     separate git projects in AOSP) and concatenates the result into a
     single patch file, formatted like the original.

Usage:
  python3 make_rbe_patch.py \
      --aosp-root /path/to/aosp \
      --old-dir-name live \
      --new-dir-name buildbuddyfix \
      --extra-flag "-canonicalize_working_dir" \
      --output android-rbe-buildbuddyfix-defaults.patch

Run with --dry-run first to preview changes without touching files.
"""

import argparse
import re
import subprocess
import sys
from pathlib import Path


# Each entry: (relative path from aosp root, git repo it belongs to)
# build/make and build/soong are separate git projects in the AOSP
# multi-repo layout, so diffs must be generated per-repo.
TARGET_FILES = [
    ("build/make/core/rbe.mk", "build/make"),
    ("build/soong/remoteexec/remoteexec.go", "build/soong"),
    ("build/soong/remoteexec/remoteexec_test.go", "build/soong"),
    ("build/soong/android/config.go", "build/soong"),
    ("build/soong/ui/build/config.go", "build/soong"),
    ("build/make/rbesetup.sh", "build/make"),
    ("build/soong/docs/rbe.json", "build/soong"),
]


def replace_dir_name(text: str, old_dir_name: str, new_dir_name: str) -> tuple[str, int]:
    """Replace occurrences of prebuilts/remoteexecution-client/<old>(/) with <new>.

    Matches 'live', 'latest', or whatever old_dir_name is, immediately after
    'prebuilts/remoteexecution-client/', with or without a trailing slash.
    """
    pattern = re.compile(
        r"(prebuilts/remoteexecution-client/)" + re.escape(old_dir_name) + r"(/?)"
    )
    count = 0

    def _sub(m: re.Match) -> str:
        nonlocal count
        count += 1
        return f"{m.group(1)}{new_dir_name}{m.group(2)}"

    new_text = pattern.sub(_sub, text)
    return new_text, count


def add_wrapper_flag(text: str, extra_flag: str) -> tuple[str, int]:
    """Append extra_flag to lines that set a bare rewrapper wrapper path.

    This targets the specific lines the original patch touched:
      - RBE_WRAPPER := $(rbe_dir)/rewrapper                     (rbe.mk, Makefile syntax)
      - return c.GetenvWithDefault("RBE_WRAPPER", remoteexec.DefaultWrapperPath)  (config.go)
    Adjust the patterns below if your own files differ.
    """
    count = 0
    out_lines = []
    for line in text.splitlines(keepends=True):
        stripped = line.rstrip("\n")

        # Makefile: RBE_WRAPPER := $(rbe_dir)/rewrapper
        m1 = re.match(r"^(\s*RBE_WRAPPER\s*:=\s*\$\(rbe_dir\)/rewrapper)(\s*)$", stripped)
        if m1:
            out_lines.append(f"{m1.group(1)} {extra_flag}\n")
            count += 1
            continue

        # Go: return c.GetenvWithDefault("RBE_WRAPPER", remoteexec.DefaultWrapperPath)
        m2 = re.match(
            r'^(\s*return c\.GetenvWithDefault\("RBE_WRAPPER", remoteexec\.DefaultWrapperPath)(\))(\s*)$',
            stripped,
        )
        if m2:
            out_lines.append(f'{m2.group(1)}+" {extra_flag}"{m2.group(2)}\n')
            count += 1
            continue

        out_lines.append(line)

    return "".join(out_lines), count


def process_file(path: Path, old_dir_name: str, new_dir_name: str,
                  extra_flag: str | None, dry_run: bool) -> int:
    if not path.exists():
        print(f"  [skip] {path} (not found)")
        return 0

    original = path.read_text()
    text = original

    text, dir_hits = replace_dir_name(text, old_dir_name, new_dir_name)

    flag_hits = 0
    if extra_flag:
        text, flag_hits = add_wrapper_flag(text, extra_flag)

    total_hits = dir_hits + flag_hits
    if total_hits == 0:
        print(f"  [none] {path} (no matches)")
        return 0

    print(f"  [edit] {path}: {dir_hits} dir-name replacement(s), "
          f"{flag_hits} wrapper-flag insertion(s)")

    if not dry_run and text != original:
        path.write_text(text)

    return total_hits


def git_diff(repo_dir: Path) -> str:
    result = subprocess.run(
        ["git", "diff", "--no-color"],
        cwd=repo_dir,
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode not in (0, 1):
        # git diff returns 1 if there are differences under some configs; treat >1 as real error
        print(f"warning: git diff in {repo_dir} exited {result.returncode}: {result.stderr}",
              file=sys.stderr)
    return result.stdout


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                      formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--aosp-root", required=True, type=Path,
                         help="Path to the root of your AOSP checkout")
    parser.add_argument("--old-dir-name", default="live",
                         help="Existing directory name under "
                              "prebuilts/remoteexecution-client/ to replace "
                              "(default: live)")
    parser.add_argument("--new-dir-name", required=True,
                         help="Your replacement directory name, e.g. buildbuddyfix")
    parser.add_argument("--extra-flag", default=None,
                         help="Optional flag to append to default rewrapper "
                              "invocations, e.g. -canonicalize_working_dir")
    parser.add_argument("--output", default="rbe-defaults.patch",
                         help="Output patch file path")
    parser.add_argument("--dry-run", action="store_true",
                         help="Preview changes without writing files or generating a patch")
    args = parser.parse_args()

    aosp_root = args.aosp_root.resolve()
    if not aosp_root.is_dir():
        sys.exit(f"error: {aosp_root} is not a directory")

    print(f"AOSP root: {aosp_root}")
    print(f"Replacing 'prebuilts/remoteexecution-client/{args.old_dir_name}' "
          f"-> 'prebuilts/remoteexecution-client/{args.new_dir_name}'")
    if args.extra_flag:
        print(f"Appending flag to default rewrapper invocations: {args.extra_flag}")
    print()

    total_changes = 0
    touched_repos = set()

    for rel_path, repo in TARGET_FILES:
        full_path = aosp_root / rel_path
        hits = process_file(full_path, args.old_dir_name, args.new_dir_name,
                             args.extra_flag, args.dry_run)
        if hits:
            touched_repos.add(repo)
        total_changes += hits

    print()
    if total_changes == 0:
        print("No changes made. Check --old-dir-name / file paths / that files "
              "haven't already been patched.")
        return

    if args.dry_run:
        print(f"[dry-run] Would have made {total_changes} change(s) across "
              f"{len(touched_repos)} repo(s). No files written, no patch generated.")
        return

    print(f"Made {total_changes} change(s) across {len(touched_repos)} repo(s).")
    print("Generating patch...")

    patch_parts = []
    for repo in sorted(touched_repos):
        repo_dir = aosp_root / repo
        diff_text = git_diff(repo_dir)
        if diff_text.strip():
            patch_parts.append(diff_text)

    combined = "\n".join(patch_parts) if patch_parts else ""
    output_path = Path(args.output).resolve()
    output_path.write_text(combined)

    print(f"Wrote patch to {output_path}")
    print()
    print("Review it with:")
    print(f"  less {output_path}")
    print("Apply it elsewhere with (run from aosp root, once per repo it touches):")
    for repo in sorted(touched_repos):
        print(f"  cd {repo} && git apply /path/to/{output_path.name}")


if __name__ == "__main__":
    main()
