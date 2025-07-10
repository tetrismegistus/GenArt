from PIL import Image
import os
from pathlib import Path

# Define root path
sketches_root = Path("sketches")

# Supported extensions
extensions = [".png", ".jpg", ".jpeg"]

# Traverse sketches dir recursively
for ext in extensions:
    for img_path in sketches_root.rglob(f"*{ext}"):
        webp_path = img_path.with_suffix(".webp")

        # Skip if already exists
        if webp_path.exists():
            print(f"⚠️  Skipping (already exists): {webp_path}")
            continue

        try:
            with Image.open(img_path) as im:
                im.save(webp_path, "WEBP", quality=95)
                print(f"✅ Converted: {img_path} → {webp_path}")
        except Exception as e:
            print(f"❌ Error converting {img_path}: {e}")

