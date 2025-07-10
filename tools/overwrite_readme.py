import os
from pathlib import Path

# Paths
repo_root = Path(__file__).resolve().parent
template_path = repo_root / "boilerplate" / "sketch_readme_template.md"
explorations_path = repo_root / "sketches" / "explorations"

# Read template contents
with open(template_path, "r") as f:
    template_content = f.read()

# Loop over all immediate folders in explorations
for sketch_dir in explorations_path.iterdir():
    if sketch_dir.is_dir():
        readme_path = sketch_dir / "README.md"
        with open(readme_path, "w") as f:
            f.write(template_content)
        print(f"✅ Overwrote: {readme_path}")

print("🎉 All README.md files in `explorations/` updated with template.")

