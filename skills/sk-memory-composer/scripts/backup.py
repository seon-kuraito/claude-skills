#!/usr/bin/env python3
# /// script
# requires-python = ">=3.9"
# ///
"""backup — copy files and folders into a new timestamped folder before a memory change.

    uv run backup.py --dest DIR [--home DIR] PATH...

A path under the home folder keeps its path relative to home; any other path
keeps its absolute path. Prints the folder it created. Checks every PATH
before copying anything: a missing one stops the run with nothing created.
"""
import argparse
import os
import shutil
import sys
from datetime import datetime
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser(description="Back up files and folders before a memory change.")
    parser.add_argument("--dest", required=True, help="the folder to create the backup in, such as the session scratchpad")
    parser.add_argument("--home", default="~", help="the home folder paths are kept relative to (default: ~)")
    parser.add_argument("paths", nargs="+", help="the files and folders to back up")
    args = parser.parse_args()

    home = Path(os.path.abspath(Path(args.home).expanduser()))
    sources = [Path(os.path.abspath(Path(raw).expanduser())) for raw in args.paths]
    missing = [source for source in sources if not source.exists()]
    for source in missing:
        print(f"MISSING  {source}", file=sys.stderr)
    if missing:
        return 1

    stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    folder = Path(args.dest).expanduser() / f"memory-backup-{stamp}"
    suffix = 1
    while folder.exists():
        suffix += 1
        folder = Path(args.dest).expanduser() / f"memory-backup-{stamp}-{suffix}"

    for source in sources:
        try:
            relative = source.relative_to(home)
        except ValueError:
            relative = source.relative_to(source.anchor)
        target = folder / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        if source.is_dir():
            shutil.copytree(source, target, dirs_exist_ok=True)
        else:
            shutil.copy2(source, target)

    print(folder)
    return 0


if __name__ == "__main__":
    sys.exit(main())
