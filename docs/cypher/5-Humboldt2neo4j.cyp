// cypher-Humboldt
// Mit diesem Skript werden 5 Mitschriften der Kosmos-Vorträge von Alexander von Humboldt in die Graphdatenbank neo4j importiert.

// N.N.1
// http://www.deutschestextarchiv.de/book/show/nn_msgermqu2345_1827 
// http://www.deutschestextarchiv.de/book/download_xml/nn_msgermqu2345_1827 

// N.N.2
// http://www.deutschestextarchiv.de/book/show/nn_oktavgfeo79_1828 
// http://www.deutschestextarchiv.de/book/download_xml/nn_oktavgfeo79_1828 

// Patzig
// http://www.deutschestextarchiv.de/book/show/patzig_msgermfol841842_1828 
// http://www.deutschestextarchiv.de/book/download_xml/patzig_msgermfol841842_1828 

// Hufeland
// http://www.deutschestextarchiv.de/book/show/hufeland_privatbesitz_1829
// http://www.deutschestextarchiv.de/book/download_xml/hufeland_privatbesitz_1829 

// Parthey
// http://www.deutschestextarchiv.de/book/show/parthey_msgermqu1711_1828
// http://www.deutschestextarchiv.de/book/download_xml/parthey_msgermqu1711_1828 




// Alles löschen
MATCH(n) DETACH DELETE n;

// NN1 importieren #################################################################
call
apoc.xml.import('http://www.deutschestextarchiv.de/book/download_xml/nn_msgermqu2345_1827',{createNextWordRelationships: true})
yield node return node;

// Knoten durchzählen
MATCH p = (start:XmlDocument)-[:NEXT*]->(end:XmlTag)
WHERE NOT (end)-[:NEXT]->() AND start.url = 'http://www.deutschestextarchiv.de/book/download_xml/nn_msgermqu2345_1827'
WITH nodes(p) as nodes, range(0, size(nodes(p))) AS indexes
UNWIND indexes AS index
SET (nodes[index]).DtaID = index
SET (nodes[index]).Document = 'NN1';

// NN2 importieren #################################################################
call
apoc.xml.import('http://www.deutschestextarchiv.de/book/download_xml/nn_oktavgfeo79_1828',{createNextWordRelationships: true})
yield node return node;

// Knoten durchzählen
MATCH p = (start:XmlDocument)-[:NEXT*]->(end:XmlTag)
WHERE NOT (end)-[:NEXT]->() AND start.url = 'http://www.deutschestextarchiv.de/book/download_xml/nn_oktavgfeo79_1828'
WITH nodes(p) as nodes, range(0, size(nodes(p))) AS indexes
UNWIND indexes AS index
SET (nodes[index]).DtaID = index
SET (nodes[index]).Document = 'NN2';

// Patzig importieren ##################################################################
call
apoc.xml.import('http://www.deutschestextarchiv.de/book/download_xml/patzig_msgermfol841842_1828',{createNextWordRelationships: true})
yield node return node;

// Knoten durchzählen
MATCH p = (start:XmlDocument)-[:NEXT*]->(end:XmlTag)
WHERE NOT (end)-[:NEXT]->() AND start.url = 'http://www.deutschestextarchiv.de/book/download_xml/patzig_msgermfol841842_1828'
WITH nodes(p) as nodes, range(0, size(nodes(p))) AS indexes
UNWIND indexes AS index
SET (nodes[index]).DtaID = index
SET (nodes[index]).Document = 'Patzig';;

// Hufeland importieren #################################################################
call
apoc.xml.import('http://www.deutschestextarchiv.de/book/download_xml/hufeland_privatbesitz_1829',{createNextWordRelationships: true})
yield node return node;

// Knoten durchzählen
MATCH p = (start:XmlDocument)-[:NEXT*]->(end:XmlTag)
WHERE NOT (end)-[:NEXT]->() AND start.url = 'http://www.deutschestextarchiv.de/book/download_xml/hufeland_privatbesitz_1829'
WITH nodes(p) as nodes, range(0, size(nodes(p))) AS indexes
UNWIND indexes AS index
SET (nodes[index]).DtaID = index
SET (nodes[index]).Document = 'Hufeland';

// Parthey importieren #################################################################
call
apoc.xml.import('http://www.deutschestextarchiv.de/book/download_xml/parthey_msgermqu1711_1828',{createNextWordRelationships: true})
yield node return node;

// Knoten durchzählen
MATCH p = (start:XmlDocument)-[:NEXT*]->(end:XmlTag)
WHERE NOT (end)-[:NEXT]->() AND start.url = 'http://www.deutschestextarchiv.de/book/download_xml/parthey_msgermqu1711_1828'
WITH nodes(p) as nodes, range(0, size(nodes(p))) AS indexes
UNWIND indexes AS index
SET (nodes[index]).DtaID = index
SET (nodes[index]).Document = 'Parthey';


// URL von Dokument auf alle Wort-Knoten kopieren:
match (d:XmlDocument)-[:NEXT_WORD*]->(w:XmlWord)
set w.url = d.url;
