import os
from pathlib import Path

def update_readme(readme_path, sketch_name, webp_image=None):
    with open(readme_path, 'r') as f:
        lines = f.readlines()

    # Replace first line with sketch title
    lines[0] = f"# {sketch_name}\n"

    # Update image tag if one exists
    if webp_image:
        updated = False
        for i, line in enumerate(lines):
            if "<img " in line and "src=" in line:
                lines[i] = f'<img src="{webp_image}" alt="{sketch_name} Sample Output" width="800" />\n'
                updated = True
                break
        if not updated:
            # Append if missing
            lines.append(f"\n<img src=\"{webp_image}\" alt=\"{sketch_name} Sample Output\" width=\"800\" />\n")

    # Write changes back
    with open(readme_path, 'w') as f:
        f.writelines(lines)

def process_sketches(sketch_root):
    for sketch_dir in sketch_root.iterdir():
        if not sketch_dir.is_dir():
            continue

        readme = sketch_dir / "README.md"
        if not readme.exists():
            continue

        # Grab folder name
        sketch_name = sketch_dir.name

        # Look for .webp images
        webps = sorted(sketch_dir.glob("*.webp"))
        webp_image = webps[0].name if webps else None

        update_readme(readme, sketch_name, webp_image)
        print(f"✅ Updated: {sketch_name}")

# Run for explorations and optionally for projects
base = Path("sketches")
process_sketches(base / "explorations")
process_sketches(base / "projects")  # Uncomment if desired

