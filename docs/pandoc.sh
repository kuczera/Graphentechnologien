rm pandoc/*
cp *.md pandoc/
cp index.md pandoc 01_index.md
rm pandoc/README.md
rm pandoc/contents.md
rm pandoc/credits.md
rm pandoc/index.md

cd pandoc
find . -name "*.md" -type f | xargs sed -i -e '/# Inhalt/d'
find . -name "*.md" -type f | xargs sed -i -e '/{:.no_toc}/d'
find . -name "*.md" -type f | xargs sed -i -e '/* Will be replaced with the ToC, excluding the "Contents" header/d'
find . -name "*.md" -type f | xargs sed -i -e '/{:toc}/d'

cat pandoc/*.md > pandoc/allpages.txt
mv pandoc/allpages.txt .
 

allpages:
pandoc -N --variable mainfont="Palatino" --variable sansfont="Helvetica" --variable monofont="Menlo" --variable fontsize=12pt --variable version=2.0 allpages.txt --toc -o allpages.pdf

Einführung und Theorie
pandoc -N --variable mainfont="Palatino" --variable sansfont="Helvetica" --variable monofont="Menlo" --variable fontsize=12pt --variable version=2.0 05_Einfuehrung_und_Theorie.md --toc -o 05_Einfuehrung_und_Theorie.pdf

Das Projekt Regesta Imperii oder "Wie suchen Onlinenutzer Regesten"
pandoc -N --variable mainfont="Palatino" --variable sansfont="Helvetica" --variable monofont="Menlo" --variable fontsize=12pt --variable version=2.0 10_Regesta-Imperii.md --toc -o 10_Regesta-Imperii.pdf

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
