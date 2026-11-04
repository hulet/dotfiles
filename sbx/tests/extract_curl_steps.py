"""Write every curl-using install step to <out>/<kit>-<n>.sh; print the count."""
import pathlib
import re
import sys

import yaml

root, out = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
out.mkdir(parents=True, exist_ok=True)
count = 0
for spec_path in sorted((root / "kits").glob("*/spec.yaml")):
    spec = yaml.safe_load(spec_path.read_text())
    for i, step in enumerate((spec.get("setup") or {}).get("install") or []):
        command = step.get("command", "")
        if isinstance(command, str) and re.search(r"\bcurl\b", command):
            (out / f"{spec_path.parent.name}-{i + 1}.sh").write_text(command)
            count += 1
print(count)
