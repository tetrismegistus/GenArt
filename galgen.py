#!/usr/bin/env python3
from pathlib import Path
import argparse, re
from typing import List, Tuple, Optional

START = "<!-- GALLERY:START -->"
END   = "<!-- GALLERY:END -->"

def slugify(s: str) -> str:
    return re.sub(r"[^a-z0-9\-]+","-", s.strip().lower())

def nice_label(s: str) -> str:
    return " ".join(w.capitalize() for w in re.sub(r"[_-]+", " ", s).split())

def pick_webp(folder: Path) -> Optional[Path]:
    if not folder.is_dir():
        return None
    # Prefer output.webp (any case)
    for name in ("output.webp","Output.webp","OUTPUT.WEBP"):
        p = folder / name
        if p.is_file():
            return p
    cands = sorted(folder.glob("*.webp"))
    return cands[0] if cands else None

def collect_section(root: Path) -> List[Tuple[str, Path]]:
    items: List[Tuple[str, Path]] = []
    if not root.exists():
        return items
    for child in sorted([p for p in root.iterdir() if p.is_dir()]):
        img = pick_webp(child)
        if img:
            items.append((child.name, img))
    return items

def make_table(title: str, items: List[Tuple[str, Path]], rel_to: Path,
               cols: int, thumb_px: int) -> str:
    if not items:
        return f"### {title}\n\n<em>No images found.</em>\n"
    cols = max(1, cols)
    thumb_px = min(int(thumb_px), 500)  # hard cap

    # Build rows of <td> cards
    tds = []
    for folder_name, img_path in items:
        rel = img_path.relative_to(rel_to).as_posix()  # no leading "sketches/"
        label = nice_label(folder_name)
        anchor = slugify(folder_name)
        tds.append(
            f'<td align="center" valign="top" style="padding:6px;">'
            f'  <a id="{anchor}"></a>'
            f'  <a href="{rel}">'
            f'    <img src="{rel}" alt="{label}" width="{thumb_px}">'
            f'  </a><br>'
            f'  <sub>{label}</sub>'
            f'</td>'
        )

    # Chunk into rows
    rows = []
    for i in range(0, len(tds), cols):
        chunk = tds[i:i+cols]
        # pad last row so column widths remain even (optional but tidy)
        while len(chunk) < cols:
            chunk.append('<td></td>')
        rows.append("<tr>\n" + "\n".join(chunk) + "\n</tr>")

    table_html = (
        f"### {title}\n\n"
        f"<table>\n<tbody>\n" + "\n".join(rows) + "\n</tbody>\n</table>\n"
    )
    return table_html

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
    ap = argparse.ArgumentParser(description="Generate a GitHub-friendly WEBP gallery as an HTML table.")
    ap.add_argument("--dest", default="sketches/Gallery.md",
                    help="Output Markdown file (e.g., sketches/Gallery.md or sketches/README.md)")
    ap.add_argument("--cols", type=int, default=4,
                    help="Number of columns in the table")
    ap.add_argument("--thumb", type=int, default=220,
                    help="Thumbnail width in px (max 500)")
    ap.add_argument("--title", default="## Gallery",
                    help="Top-level section title")
    args = ap.parse_args()

    dest = Path(args.dest)
    dest.parent.mkdir(parents=True, exist_ok=True)

    base = dest.parent  # sketches/
    expl_root = base / "explorations"
    proj_root = base / "projects"

    explorations = collect_section(expl_root)
    projects     = collect_section(proj_root)

    toc = []
    if explorations: toc.append("- [Explorations](#explorations)")
    if projects:     toc.append("- [Projects](#projects)")
    toc_md = ("\n".join(toc) + "\n\n") if toc else ""

    sections = []
    if explorations:
        sections.append(make_table("Explorations", explorations, rel_to=base, cols=args.cols, thumb_px=args.thumb))
    if projects:
        sections.append(make_table("Projects", projects, rel_to=base, cols=args.cols, thumb_px=args.thumb))

    body = args.title + "\n\n" + toc_md + ("".join(sections) if sections else "_No images found._\n")
    upsert_block(dest, body)

if __name__ == "__main__":
    main()

