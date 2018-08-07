cat *.md > allpages.txt
pandoc -N --variable mainfont="Palatino" --variable sansfont="Helvetica" --variable monofont="Menlo" --variable fontsize=12pt --variable version=2.0 allpages.txt --toc -o example14.pdf
