#!/usr/bin/env python3
from pathlib import Path
import re
import argparse
from typing import List, Tuple, Optional

START = "<!-- GALLERY:START -->"
END = "<!-- GALLERY:END -->"

def slugify(s: str) -> str:
    return re.sub(r"[^a-z0-9\-]+","-", s.strip().lower())

def nice_label(s: str) -> str:
    return " ".join(w.capitalize() for w in re.sub(r"[_-]+", " ", s).split())

def pick_webp(folder: Path) -> Optional[Path]:
    """Prefer output.webp (any case), else first *.webp in the folder."""
    if not folder.is_dir():
        return None
    for name in ("output.webp", "Output.webp", "OUTPUT.WEBP"):
        p = folder / name
        if p.is_file():
            return p
    cands = sorted(folder.glob("*.webp"))
    return cands[0] if cands else None

def collect_section(root: Path) -> List[Tuple[str, Path]]:
    """Return (folder_name, image_path) for each immediate subfolder that has a webp."""
    if not root.exists():
        return []
    items: List[Tuple[str, Path]] = []
    for child in sorted([p for p in root.iterdir() if p.is_dir()]):
        img = pick_webp(child)
        if img:
            items.append((child.name, img))
    return items

def make_grid(title: str, items: List[Tuple[str, Path]], rel_to: Path,
              thumb_px: int, gap_px: int) -> str:
    """
    GitHub ignores CSS Grid; use Flexbox + width attribute.
    Enforce a hard cap of 500px for both width & height (contain).
    """
    if not items:
        return f"### {title}\n\n<em>No images found.</em>\n"

    # Enforce the 500×500 maximum regardless of what the user passes
    thumb_px = min(int(thumb_px), 500)

    cards = []
    for folder_name, img_path in items:
        rel = img_path.relative_to(rel_to).as_posix()   # no leading "sketches/"
        label = nice_label(folder_name)
        anchor = slugify(folder_name)

        # width attribute is honored by GitHub. We also add max-height with object-fit:contain
        # so tall images don’t exceed 500px height.
        card = (
            f'<div style="width:{thumb_px}px;margin:{gap_px//2}px">'
            f'  <a id="{anchor}"></a>'
            f'  <a href="{rel}" style="text-decoration:none">'
            f'    <img src="{rel}" alt="{label}" loading="lazy" '
            f'         width="{thumb_px}" '
            f'         style="display:block;border-radius:10px;'
            f'                max-height:500px;object-fit:contain" />'
            f'  </a>'
            f'  <div style="font-size:0.9em;margin-top:6px;text-align:center">{label}</div>'
            f'</div>'
        )
        cards.append(card)

    return (
        f"### {title}\n\n"
        f'<div style="display:flex;flex-wrap:wrap;align-items:flex-start;'
        f'margin:-{gap_px//2}px">'
        + "".join(cards) +
        "</div>\n"
    )

def upsert_block(doc: Path, content: str) -> None:
    block = f"{START}\n{content}\n{END}\n"
    if doc.exists():
        txt = doc.read_text(encoding="utf-8")
        pat = re.compile(re.escape(START) + r".*?" + re.escape(END), re.DOTALL)
        txt = pat.sub(block, txt) if pat.search(txt) else txt.rstrip() + "\n\n" + block
    else:
        txt = block
    doc.write_text(txt, encoding="utf-8")

def main():
    ap = argparse.ArgumentParser(description="Generate a GitHub-friendly WEBP gallery.")
    ap.add_argument("--dest", default="sketches/Gallery.md",
                    help="Target Markdown file (e.g., sketches/Gallery.md or sketches/README.md)")
    ap.add_argument("--thumb", type=int, default=220,
                    help="Thumbnail width in px (hard-capped at 500)")
    ap.add_argument("--gap", type=int, default=10,
                    help="Gap between items in px")
    ap.add_argument("--title", default="## Gallery",
                    help="Section title")
    args = ap.parse_args()

    dest = Path(args.dest)
    dest.parent.mkdir(parents=True, exist_ok=True)

    base = dest.parent            # sketches/
    expl_root = base / "explorations"
    proj_root = base / "projects"

    explorations = collect_section(expl_root)
    projects = collect_section(proj_root)

    toc = []
    if explorations: toc.append("- [Explorations](#explorations)")
    if projects:     toc.append("- [Projects](#projects)")
    toc_md = ("\n".join(toc) + "\n\n") if toc else ""

    sections = []
    if explorations:
        sections.append(
            make_grid("Explorations", explorations, rel_to=base,
                      thumb_px=args.thumb, gap_px=args.gap)
        )
    if projects:
        sections.append(
            make_grid("Projects", projects, rel_to=base,
                      thumb_px=args.thumb, gap_px=args.gap)
        )

    body = args.title + "\n\n" + toc_md + ("".join(sections) if sections else "_No images found._\n")
    upsert_block(dest, body)

if __name__ == "__main__":
    main()

