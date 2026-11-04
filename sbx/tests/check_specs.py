"""Static checks for dotfiles/sbx/kits: fields, catalogs, checksum pinning."""
import json
import pathlib
import re
import sys

import yaml

REQUIRED = ("schemaVersion", "kind", "name", "displayName", "description")
CATALOG_ITEM = re.compile(r"^\s*- \*\*`([a-z0-9-]+)`\*\*")
SHA256 = re.compile(r"\b[0-9a-f]{64}\b")
AGENT_PATH = re.compile(r"/home/agent/[A-Za-z0-9._/-]+")


def catalog(text, heading):
    """Kit names listed as '- **`name`**' under a markdown heading."""
    names, inside = set(), False
    for line in text.splitlines():
        if line.strip() == heading:
            inside = True
            continue
        if inside and line.lstrip().startswith("#"):
            break
        match = CATALOG_ITEM.match(line)
        if inside and match:
            names.add(match.group(1))
    return names


def main(root):
    kits_dir = pathlib.Path(root) / "kits"
    errors = []
    names = sorted(p.name for p in kits_dir.iterdir() if p.is_dir())
    if not names:
        errors.append("no kits found under sbx/kits/")
    specs = {}
    for name in names:
        path = kits_dir / name / "spec.yaml"
        if not path.is_file():
            errors.append(f"{name}: missing spec.yaml")
            continue
        spec = yaml.safe_load(path.read_text()) or {}
        if not isinstance(spec, dict):
            errors.append(f"{name}: spec.yaml is empty or not a mapping")
            continue
        specs[name] = spec
        for field in REQUIRED:
            if not spec.get(field):
                errors.append(f"{name}: missing {field}")
        if str(spec.get("schemaVersion")) != "2":
            errors.append(f"{name}: schemaVersion must be '2'")
        if spec.get("kind") != "mixin":
            errors.append(f"{name}: kind must be mixin")
        if spec.get("name") != name:
            errors.append(f"{name}: name must equal the directory name")
        if not (spec.get("agentInstructions") or {}).get("content"):
            errors.append(f"{name}: missing agentInstructions.content")
        has_curl = False
        for i, step in enumerate((spec.get("setup") or {}).get("install") or []):
            where = f"{name}: install step {i + 1}"
            if not step.get("description"):
                errors.append(f"{where}: missing description")
            command = step.get("command", "")
            if not isinstance(command, str) or not re.search(r"\bcurl\b", command):
                continue
            if "sha256sum -c" not in command:
                errors.append(f"{where}: downloads with curl but never runs sha256sum -c")
            if len(set(SHA256.findall(command))) < 2:
                errors.append(f"{where}: needs an embedded SHA256 per architecture")
            if re.search(r"checksums|SHASUMS|\.sha256\b|\.sig\b", command):
                errors.append(f"{where}: must not fetch checksums or signatures at install time")
            has_curl = True
        if has_curl and "Updating a pinned tool" not in path.read_text():
            errors.append(
                f"{name}: pinned steps need a comment pointing to sbx/kits/README.md, 'Updating a pinned tool'"
            )
    base = specs.get("base")
    if not base:
        errors.append("sbx/kits/base is required")
    else:
        content = (base.get("agentInstructions") or {}).get("content", "")
        listed = catalog(content, "### Kit catalog")
        if listed != set(names):
            errors.append(f"base catalog lists {sorted(listed)}, sbx/kits/ has {names}")
    home = kits_dir / "base" / "files" / "home"
    settings = home / "sbx-claude-settings.json"
    texts = {f"{n}/spec.yaml": (kits_dir / n / "spec.yaml") for n in specs}
    if settings.is_file():
        try:
            json.loads(settings.read_text())
        except ValueError as exc:
            errors.append(f"base: sbx-claude-settings.json is not valid JSON: {exc}")
        texts["base/sbx-claude-settings.json"] = settings
    else:
        errors.append("base: files/home/sbx-claude-settings.json is missing")
    for label, path in texts.items():
        for ref in sorted(set(AGENT_PATH.findall(path.read_text()))):
            rel = ref[len("/home/agent/"):].rstrip("./-")
            if rel and not (home / rel).exists():
                errors.append(f"{label}: {ref} has no sbx/kits/base/files/home/{rel}")
    readme = kits_dir / "README.md"
    if readme.is_file():
        listed = catalog(readme.read_text(), "## Kit catalog")
        if listed != set(names):
            errors.append(f"sbx/kits/README.md catalog lists {sorted(listed)}, sbx/kits/ has {names}")
    else:
        errors.append("sbx/kits/README.md is missing")
    for error in errors:
        print(f"  not ok: {error}", file=sys.stderr)
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]))
