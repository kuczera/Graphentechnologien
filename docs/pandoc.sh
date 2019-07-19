Anleitung zur Erstellung eines PDFs des Github-Buches

Ausgangspunkt ist das docs-Verzeichnis.

mkdir /tmp/pandoc/
cp -r Bilder/ /tmp/
cp *.md /tmp/pandoc/
rm /tmp/pandoc/README.md
rm /tmp/pandoc/contents.md
rm /tmp/pandoc/credits.md
rm /tmp/pandoc/index.md
cat /tmp/pandoc/*.md > /tmp/pandoc/allpages.txt

cd /tmp/pandoc
find . -name "allpages.txt" -type f | xargs sed -i -e '/# Inhalt/d'
find . -name "allpages.txt" -type f | xargs sed -i -e '/# Inhalt/d'
find . -name "allpages.txt" -type f | xargs sed -i -e '/{:.no_toc}/d'
find . -name "allpages.txt" -type f | xargs sed -i -e '/* Will be replaced with the ToC, excluding the "Contents" header/d'
find . -name "allpages.txt" -type f | xargs sed -i -e '/{:toc}/d'

Mit diesem Befehl werden alle Titelzeilen gelöscht:

sed -i '/---/,/^$/d' allpages.txt

cp /tmp/pandoc/allpages.txt /tmp/allpages.txt

rm -r /tmp/pandoc/*

rm -r /tmp/Bilder/

Dann den Haupttitel wieder in allpages.txt einfügen:

---
title: Graphentechnologien in den Digitalen Geisteswissenschaften
subtitle: Modellierung – Import – Analyse
author:
- Andreas Kuczera
lang: de
---

Jetzt kann mit pandoc das PDF erstellt werden:

allpages:
/usr/bin/pandoc -N --variable mainfont="Palatino" --variable sansfont="Helvetica" --variable monofont="Menlo" --variable fontsize=12pt --variable version=2.0 allpages.txt --toc -o allpages.pdf

pandoc -N --variable mainfont="Palatino" --variable sansfont="Helvetica" --variable monofont="Menlo" --variable fontsize=12pt --variable version=2.0 allpages.txt --toc -o allpages.pdf

Erstellung von PDFs der Einzelkapitel:

Einführung und Theorie
/usr/bin/pandoc -N --variable mainfont="Palatino" --variable sansfont="Helvetica" --variable monofont="Menlo" --variable fontsize=12pt --variable version=2.0 05_Einfuehrung_und_Theorie.md --toc -o 05_Einfuehrung_und_Theorie.pdf

Das Projekt Rpandegesta Imperii oder "Wie suchen Onlinenutzer Regesten"
/usr/bin/pandoc -N --variable mainfont="Palatino" --variable sansfont="Helvetica" --variable monofont="Menlo" --variable fontsize=12pt --variable version=2.0 10_Regesta-Imperii.md --toc -o 10_Regesta-Imperii.pdf

Regesten im Graphen
/usr/bin/pandoc -N --variable mainfont="Palatino" --variable sansfont="Helvetica" --variable monofont="Menlo" --variable fontsize=12pt --variable version=2.0 20_Regestenmodellierung-im-Graphen.md --toc -o RI2Graph.pdf

XML2Graph
/usr/bin/pandoc -N --variable mainfont="Palatino" --variable sansfont="Helvetica" --variable monofont="Menlo" --variable fontsize=12pt --variable version=2.0 25_xml2neo4j-kollatz.md --toc -o XML.pdf

Verwandtschaft2Graph
/usr/bin/pandoc -N --variable mainfont="Palatino" --variable sansfont="Helvetica" --variable monofont="Menlo" --variable fontsize=12pt --variable version=2.0 30_Verwandtschaft-im-Graphen.md --toc -o Verwandtschaft.pdf

DTA:
/usr/bin/pandoc -N --variable mainfont="Palatino" --variable sansfont="Helvetica" --variable monofont="Menlo" --variable fontsize=12pt --variable version=2.0 45_Das-DTA-im-Graphen.md --toc -o DTA.pdf

XML-Text2Graph
/usr/bin/pandoc -N --variable mainfont="Palatino" --variable sansfont="Helvetica" --variable monofont="Menlo" --variable fontsize=12pt --variable version=2.0 60_XML-Text-im-Graphen.md --toc -o XML-Text2Graph.pdf
