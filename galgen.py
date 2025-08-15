#!/usr/bin/env python3
from pathlib import Path
import re
import argparse
from typing import List, Tuple

START = "<!-- GALLERY:START -->"
END = "<!-- GALLERY:END -->"

def slugify(s: str) -> str:
    return re.sub(r"[^a-z0-9\-]+","-", s.strip().lower())

def nice_label(s: str) -> str:
    return " ".join(w.capitalize() for w in re.sub(r"[_-]+", " ", s).split())

def pick_webp(folder: Path) -> Path | None:
    if not folder.is_dir(): return None
    for name in ("output.webp", "Output.webp", "OUTPUT.WEBP"):
        p = folder / name
        if p.is_file(): return p
    c = sorted(folder.glob("*.webp"))
    return c[0] if c else None

def collect_section(root: Path) -> List[Tuple[str, Path]]:
    items: List[Tuple[str, Path]] = []
    if not root.exists(): return items
    for child in sorted(p for p in root.iterdir() if p.is_dir()):
        img = pick_webp(child)
        if img: items.append((child.name, img))
    return items

def make_grid(title: str, items: List[Tuple[str, Path]], rel_to: Path, min_col_px=200, gap_px=10) -> str:
    if not items:
        return f"### {title}\n\n<em>No images found.</em>\n"
    cards = []
    for folder_name, img_path in items:
        rel = img_path.relative_to(rel_to).as_posix()  # <<< no leading "sketches/"
        label = nice_label(folder_name)
        anchor = slugify(folder_name)
        cards.append(
            f'<div>'
            f'  <a id="{anchor}"></a>'
            f'  <a href="{rel}" style="text-decoration:none">'
            f'    <img src="{rel}" alt="{label}" loading="lazy" style="width:100%;height:auto;border-radius:10px;display:block" />'
            f'  </a>'
            f'  <div style="font-size:0.9em;margin-top:6px;text-align:center">{label}</div>'
            f'</div>'
        )
    # CSS Grid; auto-fills columns, wraps cleanly
    return (
        f"### {title}\n\n"
        f'<div style="display:grid;grid-template-columns:repeat(auto-fill,minmax({min_col_px}px,1fr));gap:{gap_px}px;align-items:start;">'
        + "".join(cards) +
        "</div>\n"
    )

def upsert_block(doc: Path, content: str) -> None:
    block = f"{START}\n{content}\n{END}\n"
    if doc.exists():
        txt = doc.read_text(encoding="utf-8")
        pat = re.compile(re.escape(START)+r".*?"+re.escape(END), re.DOTALL)
        txt = pat.sub(block, txt) if pat.search(txt) else txt.rstrip()+"\n\n"+block
    else:
        txt = block
    doc.write_text(txt, encoding="utf-8")

def main():
    ap = argparse.ArgumentParser(description="Generate grid gallery for explorations & projects.")
    ap.add_argument("--dest", default="sketches/Gallery.md", help="Target MD (e.g., sketches/Gallery.md)")
    ap.add_argument("--min-col", type=int, default=220, help="Min column width (px)")
    ap.add_argument("--gap", type=int, default=10, help="Gap between items (px)")
    ap.add_argument("--title", default="## Gallery", help="Section title")
    args = ap.parse_args()

    dest = Path(args.dest)
    dest.parent.mkdir(parents=True, exist_ok=True)

    # Roots relative to the repo, but we’ll build links relative to dest.parent
    base = dest.parent                      # => sketches/
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
        sections.append(make_grid("Explorations", explorations, rel_to=base, min_col_px=args.min_col, gap_px=args.gap))
    if projects:
        sections.append(make_grid("Projects", projects, rel_to=base, min_col_px=args.min_col, gap_px=args.gap))

    body = args.title + "\n\n" + toc_md + ("".join(sections) if sections else "_No images found._\n")
    upsert_block(dest, body)

if __name__ == "__main__":
    main()

