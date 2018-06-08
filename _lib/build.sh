#!/bin/bash


SRC="$(dirname "$0")"/..
LIB="$SRC"/_lib
DEST="$SRC"/downloads
FILENAMEBASE=Leitfaden_wissenschaftliches_Arbeiten
TEMPLATES="$SRC"/_includes
BUILDOPTS=(--standalone --toc --toc-depth=2 --number-sections --default-image-extension=png --wrap=none --normalize)
LATEXOPTS=(--latex-engine=xelatex --variable=documentclass=scrreprt --variable=mainfont='Linux Libertine O' --variable=sansfont='Linux Biolinum O' --variable=colorlinks --no-tex-ligatures)

cd "$SRC"/

# LATEX/PDF
pandoc -o "$DEST"/"$FILENAMEBASE".pdf "${BUILDOPTS[@]}" "${LATEXOPTS[@]}" \
       --filter "$LIB"/divtoenv.py --filter "$LIB"/internallinks.py \
       --include-in-header "$TEMPLATES"/latex-defs.tex ??_*.md

# EPUB
pandoc -o "$DEST"/"$FILENAMEBASE".epub "${BUILDOPTS[@]}" \
        --filter "$LIB"/internallinks.py ??_*.md

# ODT
pandoc -o "$DEST"/"$FILENAMEBASE".odt "${BUILDOPTS[@]}" \
        --filter "$LIB"/internallinks.py ??_*.md
