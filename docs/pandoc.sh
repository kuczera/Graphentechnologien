cat *.md > allpages.txt
allpages:
pandoc -N --variable mainfont="Palatino" --variable sansfont="Helvetica" --variable monofont="Menlo" --variable fontsize=12pt --variable version=2.0 allpages.txt --toc -o allpages.pdf

XML2Graph
pandoc -N --variable mainfont="Palatino" --variable sansfont="Helvetica" --variable monofont="Menlo" --variable fontsize=12pt --variable version=2.0 25_xml2neo4j-kollatz.md --toc -o XML.pdf


DTA:
pandoc -N --variable mainfont="Palatino" --variable sansfont="Helvetica" --variable monofont="Menlo" --variable fontsize=12pt --variable version=2.0 45_Das\ DTA\ im\ Graphen.md --toc -o DTA.pdf
