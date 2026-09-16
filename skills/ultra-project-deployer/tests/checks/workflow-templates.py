#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = ["pyyaml"]
# ///
"""workflow-templates — the shipped Pages workflows stay deployable.

The skill copies these verbatim and substitutes one placeholder. A silent edit
here produces a workflow that GitHub accepts and that never deploys.
"""
import re
import sys
from pathlib import Path

import yaml

assets = Path(__file__).resolve().parents[2] / "assets"
failures = []


def check(cond, message):
    if not cond:
        failures.append(message)


for name in ("pages-static.yml.tmpl", "pages-vite.yml.tmpl"):
    path = assets / name
    check(path.exists(), f"{name} is missing")
    if not path.exists():
        continue
    text = path.read_text()

    placeholders = set(re.findall(r"\{\{([A-Z_]+)\}\}", text))
    check(placeholders == {"DEPLOY_BRANCH"},
          f"{name} placeholders are {sorted(placeholders)}, expected only DEPLOY_BRANCH")

    workflow = yaml.safe_load(text.replace("{{DEPLOY_BRANCH}}", "main"))
    # "on" parses as the boolean True in YAML 1.1
    trigger = workflow.get("on", workflow.get(True))
    check(trigger is not None and "push" in trigger, f"{name} has no push trigger")
    check(trigger["push"]["branches"] == ["main"], f"{name} does not push-trigger on the deploy branch")
    check("workflow_dispatch" in trigger, f"{name} cannot be run by hand")

    permissions = workflow.get("permissions", {})
    check(permissions.get("pages") == "write", f"{name} lacks pages: write")
    check(permissions.get("id-token") == "write", f"{name} lacks id-token: write")
    check(permissions.get("contents") == "read", f"{name} lacks contents: read")

    concurrency = workflow.get("concurrency", {})
    check(concurrency.get("group") == "pages", f"{name} does not serialise on the pages group")
    check(concurrency.get("cancel-in-progress") is False,
          f"{name} cancels an in-progress deploy; a production deploy runs to the end")

    job = next(iter(workflow["jobs"].values()))
    check(job.get("environment", {}).get("name") == "github-pages", f"{name} does not target the github-pages environment")
    uses = [step.get("uses", "") for step in job["steps"]]
    for action in ("actions/checkout", "actions/configure-pages", "actions/upload-pages-artifact", "actions/deploy-pages"):
        check(any(u.startswith(action + "@") for u in uses), f"{name} never runs {action}")
    check(all("@" in u for u in uses if u), f"{name} has an action without a pinned version")

vite = (assets / "pages-vite.yml.tmpl").read_text()
check("actions/setup-node@" in vite, "pages-vite.yml.tmpl never sets up node")
check("npm" in vite, "pages-vite.yml.tmpl never runs a build")

for message in failures:
    print(f"FAIL  {message}")
print("---")
print(f"workflow-templates: {'pass' if not failures else str(len(failures)) + ' failed'}")
sys.exit(1 if failures else 0)
