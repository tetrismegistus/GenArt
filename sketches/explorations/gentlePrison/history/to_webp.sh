#!/bin/bash
for f in *.png; do
  echo "Converting $f"
  cwebp -q 82 -alpha_q 90 "$f" -o "${f%.png}.webp"
done
