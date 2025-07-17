import os
import shutil

# Set up paths
ROOT = os.path.abspath(os.path.dirname(__file__))
PROCESSING = os.path.join(ROOT, "processing")
SKETCHES = os.path.join(ROOT, "sketches")
EXPLORATIONS = os.path.join(SKETCHES, "explorations")
PROJECTS = os.path.join(SKETCHES, "projects")

# Create target directories
os.makedirs(EXPLORATIONS, exist_ok=True)
os.makedirs(PROJECTS, exist_ok=True)

# Move everything from processing/ to explorations/
for name in os.listdir(PROCESSING):
    src = os.path.join(PROCESSING, name)
    dst = os.path.join(EXPLORATIONS, name)

    if os.path.isdir(src):
        print(f"Moving {name} → explorations/")
        shutil.move(src, dst)

        # Add README if not present
        readme_path = os.path.join(dst, "README.md")
        if not os.path.exists(readme_path):
            with open(readme_path, "w") as f:
                f.write(f"# {name}\n\n")
                f.write("🧪 Status: Exploration\n")
                f.write("📎 Description: (Add your notes here)\n")
                f.write("🎨 Tags: \n")

print("✅ All sketches moved to `sketches/explorations/` with default READMEs.")

