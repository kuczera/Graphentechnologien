cat *.md > allpages.txt
allpages:
pandoc -N --variable mainfont="Palatino" --variable sansfont="Helvetica" --variable monofont="Menlo" --variable fontsize=12pt --variable version=2.0 allpages.txt --toc -o allpages.pdf

Das Projekt Regesta Imperii oder "Wie suchen Onlinenutzer Regesten"
pandoc -N --variable mainfont="Palatino" --variable sansfont="Helvetica" --variable monofont="Menlo" --variable fontsize=12pt --variable version=2.0 10_Regesta-Imperii.md --toc -o RI-Nutzung.pdf

Regesten im Graphen
pandoc -N --variable mainfont="Palatino" --variable sansfont="Helvetica" --variable monofont="Menlo" --variable fontsize=12pt --variable version=2.0 20_Regestenmodellierung-im-Graphen.md --toc -o RI2Graph.pdf

XML2Graph
pandoc -N --variable mainfont="Palatino" --variable sansfont="Helvetica" --variable monofont="Menlo" --variable fontsize=12pt --variable version=2.0 25_xml2neo4j-kollatz.md --toc -o XML.pdf

Verwandtschaft2Graph
pandoc -N --variable mainfont="Palatino" --variable sansfont="Helvetica" --variable monofont="Menlo" --variable fontsize=12pt --variable version=2.0 30_Verwandtschaft-im-Graphen.md --toc -o Verwandtschaft.pdf

DTA:
pandoc -N --variable mainfont="Palatino" --variable sansfont="Helvetica" --variable monofont="Menlo" --variable fontsize=12pt --variable version=2.0 45_Das-DTA-im-Graphen.md --toc -o DTA.pdf

XML-Text2Graph
pandoc -N --variable mainfont="Palatino" --variable sansfont="Helvetica" --variable monofont="Menlo" --variable fontsize=12pt --variable version=2.0 60_XML-Text-im-Graphen.md --toc -o XML-Text2Graph.pdf
