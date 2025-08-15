#!/usr/bin/env python3
from pathlib import Path
import re
import argparse
from typing import List, Tuple

START = "<!-- GALLERY:START -->"
END = "<!-- GALLERY:END -->"

EXPL_ROOT = Path("sketches/explorations")
PROJ_ROOT  = Path("sketches/projects")

def slugify(s: str) -> str:
    return re.sub(r"[^a-z0-9\-]+","-", s.strip().lower())

def nice_label(s: str) -> str:
    return " ".join(w.capitalize() for w in re.sub(r"[_-]+", " ", s).split())

def pick_webp(folder: Path) -> Path | None:
    """Prefer output.webp (case-insensitive). Otherwise first *.webp by name."""
    if not folder.is_dir():
        return None
    # prefer output.webp
    for name in ("output.webp", "Output.webp", "OUTPUT.WEBP"):
        p = folder / name
        if p.exists() and p.is_file():
            return p
    # else first .webp
    candidates = sorted(folder.glob("*.webp"))
    return candidates[0] if candidates else None

def collect_section(root: Path) -> List[Tuple[str, Path]]:
    """Return list of (folder_name, image_path) for each immediate subfolder with a webp."""
    items: List[Tuple[str, Path]] = []
    if not root.exists():
        return items
    for child in sorted([p for p in root.iterdir() if p.is_dir()]):
        img = pick_webp(child)
        if img:
            items.append((child.name, img))
    return items

def make_html_grid(title: str, items: List[Tuple[str, Path]], thumb_width=220, gap=10) -> str:
    if not items:
        return f"### {title}\n\n<em>No images found.</em>\n"
    cards = []
    for folder_name, img_path in items:
        rel = img_path.as_posix()
        label = nice_label(folder_name)
        anchor = slugify(folder_name)
        card = (
            f'<a id="{anchor}"></a>'
            f'<a href="{rel}" style="text-decoration:none;">'
            f'<img src="{rel}" alt="{label}" loading="lazy" '
            f'style="width:{thumb_width}px;height:auto;display:block;border-radius:10px;" />'
            f'</a>'
            f'<div style="font-size:0.9em;margin-top:6px;text-align:center;">{label}</div>'
        )
        cards.append(f'<div style="flex:0 0 auto">{card}</div>')
    return (
        f"### {title}\n\n"
        f'<div style="display:flex;flex-wrap:wrap;gap:{gap}px;align-items:flex-start;">'
        + "".join(cards)
        + "</div>\n"
    )

def upsert_block(doc: Path, content: str) -> None:
    start_re = re.escape(START)
    end_re = re.escape(END)
    block = f"{START}\n{content}\n{END}\n"
    if doc.exists():
        txt = doc.read_text(encoding="utf-8")
        pat = re.compile(f"{start_re}.*?{end_re}", re.DOTALL)
        if pat.search(txt):
            txt = pat.sub(block, txt)
        else:
            txt = txt.rstrip() + "\n\n" + block
    else:
        txt = block
    doc.write_text(txt, encoding="utf-8")

def main():
    ap = argparse.ArgumentParser(description="Generate gallery for explorations & projects.")
    ap.add_argument("--dest", default="Gallery.md", help="File to update (Gallery.md or README.md)")
    ap.add_argument("--thumb-width", type=int, default=220, help="Thumbnail width in px")
    ap.add_argument("--gap", type=int, default=10, help="Gap between thumbnails in px")
    args = ap.parse_args()

    explorations = collect_section(EXPL_ROOT)
    projects = collect_section(PROJ_ROOT)

    header = "## Gallery\n\n"
    toc = []
    if explorations: toc.append("- [Explorations](#explorations)")
    if projects:     toc.append("- [Projects](#projects)")
    toc_md = "\n".join(toc) + ("\n\n" if toc else "")

    body = []
    if explorations:
        body.append(make_html_grid("Explorations", explorations, args.thumb_width, args.gap))
    if projects:
        body.append(make_html_grid("Projects", projects, args.thumb_width, args.gap))

    final = header + toc_md + "\n".join(body) if body else header + "_No images found._\n"
    upsert_block(Path(args.dest), final)

if __name__ == "__main__":
    main()

