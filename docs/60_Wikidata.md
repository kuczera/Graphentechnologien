---
title: Graphergänzung aus Wikidata
layout: default
order: 60
contents: true
---

# Inhalt
{:.no_toc}

* Will be replaced with the ToC, excluding the "Contents" header
{:toc}

# Graphergänzung aus Wikidata-Daten in Neo4j

## Einführung

Mit dem [wikidata-neo4j-importer](https://github.com/findie/wikidata-neo4j-importer) ist es möglich, einen Dump von Wikidata in Neo4j zu importieren. Der Vorgang benötigt einiges an Rechenleistung  und Zeit, da der Wikidata-Dump zuletzt stark angewachsen ist. Für Testzwecke finden Sie hier eine [Neo4jWikidata-Datenbank](http://jlu-buster.mni.thm.de:7474/browser/).
In diesem Abschnitt wird beschrieben, wie man aus dem eigenen Projekt heraus, in dem es Entitäten mit Normdaten, wie z.B. Wikidata-IDs gibt, aus dem Neo4j-Wikidatagraph mit cypher Zusatzinformationen in die eigene Graph-DB einspielen kann. Damit ist es z.B. möglich, weitere Entitäten in der eigenen Datenbank mit Wikidata-IDs auszustatten.

## Testdatenbank erstellen

Mit diesen [Cypherskript](https://github.com/kuczera/Graphentechnologien/raw/master/docs/cypher/20_cypher-Datenbankerstellung.txt) können Sie eine Testdatenbank mit den Regesten Kaiser Heinrichs IV. erstellen. Wenn der Import läuft ist Zeit für einen Kaffee. Die einzelnen Schritte werden [hier](https://kuczera.github.io/Graphentechnologien/20_Regestenmodellierung-im-Graphen.html) beschrieben.

## Regestengraphmodell

Im [Abschnitt zur explorativen Datenanalyse](https://kuczera.github.io/Graphentechnologien/95_Anhang.html#explorative-datenanalyse-oder-was-ist-in-der-datenbank) wird erklärt, wie man sich einen Überblick zu den in der Datenbank vorhandenen Daten verschafft. Für dieses Beispiel hier liegt der Fokus auf den Knoten mit dem Laben IndexPerson. Dies sind Personen aus dem Register des Regesten Kaiser Heinrichs IV. Einige der IndexPerson-Knoten haben auch eine WikidataId
Mit dem folgenden Query werden die WikidataIds und die Namen der IndexPerson-Knoten angezeigt:

~~~
MATCH (n:IndexPerson)
WHERE n.wikidataId IS NOT NULL
RETURN n.wikidataId, n.label;
~~~

## Regestengraph aus Neo4jWikidata-Datenbank ergänzen

In diesem Abschnitt werden Queries zur Ergänzung von Verwandtschaftsinformationen vorgestellt.

Vorab die Information, das man für den Fall das etwas schiefgeht die Wikidataknoten mit folgendem Query wieder gelöscht werden können:

~~~
MATCH (n:IndexPerson {source:'wikidata'}) DETACH DELETE n;
~~~



### Eltern ergänzen

Für diese Personen sollen nun zusätzliche Informationen aus der Neo4jWikidata-Datenbank ergänzt werden. Der entsprechende Query sieht wie folgt aus:

~~~
// IS_CHILD_OF erstellen
MATCH (n:IndexPerson)
WHERE n.wikidataId IS NOT NULL
AND n.wikidataId <> ""
WITH collect(n.wikidataId) as wis
call apoc.bolt.load("bolt://neo4j:1234@wikidata.mni.thm.de:7687","
MATCH (p:Entity)<-[rp:FATHER|MOTHER]-(n:Entity)
WHERE n.id in $wis AND p.label IS NOT NULL
RETURN p.label AS pLabel, p.id AS pId, n.id as nId;", {wis:wis}) yield row
MATCH (n2:IndexPerson{wikidataId: row.nId})
MERGE (p:IndexPerson {wikidataId:row.pId})
ON CREATE SET p.source = 'wikidata'
ON CREATE SET p.label = row.pLabel
MERGE (n2)-[rel:IS_CHILD_OF]->(p)
RETURN *;
~~~

### Ehepartner erstellen

Mit dem folgenden Query werden zu den IndexPerson-Knoten die Ehepartner aus der Neo4jWikidata-Datenbank ergänzt. Zu beachten ist, dass diese Abfrage auch IndexPerson-Knoten einbezieht, die im vorherigen Schritt erst erzeugt wurden.

~~~
// SPOUSE erstellen
MATCH (n:IndexPerson)
WHERE n.wikidataId IS NOT NULL
AND n.wikidataId <> ""
WITH collect(n.wikidataId) as wis
call apoc.bolt.load("bolt://neo4j:1234@wikidata.mni.thm.de:7687","
MATCH (p:Entity)<-[rp:SPOUSE]-(n:Entity)
WHERE n.id in $wis AND p.label IS NOT NULL
RETURN p.label AS pLabel, p.id AS pId, n.id as nId;", {wis:wis}) yield row
MATCH (n2:IndexPerson{wikidataId: row.nId})
MERGE (p:IndexPerson {wikidataId:row.pId})
ON CREATE SET p.source = 'wikidata'
ON CREATE SET p.label = row.pLabel
MERGE (n2)-[rel1:SPOUSE]->(p)
MERGE (n2)<-[rel2:SPOUSE]-(p)
RETURN *;
~~~

### Kinder ergänzen

Mit dem folgenden Query werden zu den IndexPerson-Knoten aus dem RI-Register die Kinder aus der Neo4jWikidata-Datenbank ergänzt. Zu beachten ist, dass diese Abfrage auch IndexPerson-Knoten einbezieht, die in den vorherigen Schritten erzeugt wurde.

~~~
//  Eltern mit IS_CHILD_OF erstellen
MATCH (n:IndexPerson)
WHERE n.wikidataId IS NOT NULL
AND n.wikidataId <> ""
WITH collect(n.wikidataId) as wis
call apoc.bolt.load("bolt://neo4j:1234@wikidata.mni.thm.de:7687","
MATCH (p:Entity)-[rp:FATHER|MOTHER]->(n:Entity)
WHERE n.id in $wis AND p.label IS NOT NULL
RETURN p.label AS pLabel, p.id AS pId, n.id as nId;", {wis:wis}) yield row
MATCH (n2:IndexPerson{wikidataId: row.nId})
MERGE (p:IndexPerson {wikidataId:row.pId})
ON CREATE SET p.source = 'wikidata'
ON CREATE SET p.label = row.pLabel
MERGE (n2)<-[rel:IS_CHILD_OF]-(p)
RETURN *;
~~~

### Labels ergänzen

Mit dem folgenden Query werden für IndexPerson-Knoten, die aus der Neo4jWikidata-Datenbank importiert wurden, ggf. noch Label-Angaben ergänzt, falls sie noch nicht vorhanden sind.

~~~
// Labels ergänzen
MATCH (ip:IndexPerson)
WHERE ip.source = 'wikidata'
AND ip.label IS NULL
OR ip.label = ""
WITH collect(ip.wikidataId) as wis
call apoc.bolt.load("bolt://neo4j:1234@wikidata.mni.thm.de:7687","
MATCH (p:Entity)
WHERE p.id in $wis AND p.label IS NOT NULL
RETURN p.label AS pLabel, p.id AS pId;", {wis:wis}) yield row
MATCH (p:IndexPerson {wikidataId:row.pId})
SET p.label = row.pLabel
RETURN *;
~~~

### Zusammenfassung

In diesem Abschnitt wird am Beispiel der Regesta Imperii und Wikidata erklärt, wie man aus einer bestehenden Neo4j-Datenbank heraus mit cypher-Queries Informationen aus einer anderen Neo4j-Datenbank abfragen und ergänzen kann.





# Graphergänzung aus Wikidata mit SPARQL

## Vorbemerkung

In vielen Projekten werden Entitäten über Normdatenprovider wie GND oder Wikidata identifiziert. Damit wird es möglich, Forschungsdaten über das eigene Forschungsdatenrepositorium hinaus zu vernetzen. Damit können andere Forschende auf die eigenen Forschungsdaten strukturiert zugreifen und sie in die eigenen Forschungszusammenhänge einfließen lassen. Zugleich bietet die Vernetzung einem selbst aber auch die Möglichkeit, Informationen aus anderen Forschungszusammenhängen in die eigene Arbeit einzubeziehen. In diesem Kapitel wird ausgehend von einer vorhandenen Graphdatenbank gezeigt, wie die eigenen Forschungsdaten durch zusätzliche Informationen aus Wikidata ergänzt werden können.

## Ausgangsdaten

Bei den Ausgangsdaten handelt es sich im Briefnetzwerke von wichtigen Philosophen des deutschen Idealismus und deren Korrespondenzpartnern nämlich [Kant](https://de.wikipedia.org/wiki/Immanuel_Kant), [Hölderlin](), [Schelling](https://de.wikipedia.org/wiki/Friedrich_Schelling), [Hegel](https://de.wikipedia.org/wiki/Hegel), [Caroline Schelling](https://de.wikipedia.org/wiki/Caroline_Schelling, [Fichte](https://de.wikipedia.org/wiki/Johann_Gottlieb_Fichte), [Reinhold](https://de.wikipedia.org/wiki/Karl_Leonhard_Reinhold) und [Jacobi](https://de.wikipedia.org/wiki/Friedrich_Heinrich_Jacobi).

Mit dem folgenden Queries wird die Datenbank erstellt:


~~~cypher
// Kant / Hölderlin / Schelling / Hegel / Caroline Schelling / Fichte / Reinhold / Jacobi
// ['118559796', '118551981', '118607057', '118547739', '118607049', '118532847', '118599410', '118556312']
UNWIND ['118559796', '118551981', '118607057', '118547739', '118607049', '118532847', '118599410', '118556312'] AS xmlId
WITH 'https://correspsearch.net/api/v1.1/tei-xml.xql?correspondent=http://d-nb.info/gnd/' + xmlId as url
CALL apoc.load.xml(url,'//*[local-name()="profileDesc"]/*',{}, true) yield value as correspDesc
WITH correspDesc,
[x in correspDesc._correspDesc WHERE x.type="sent"][0] as sent,
[x in correspDesc._correspDesc WHERE x.type="received"][0] as received
WITH correspDesc, sent, received,
     [x in sent._correspAction WHERE x._type="persName"][0] as sentPerson,
     [x in sent._correspAction WHERE x._type="date"][0] as sentDate,
     [x in sent._correspAction WHERE x._type="placeName"][0] as sentPlaceName,
     [x in received._correspAction WHERE x._type="persName"][0] as receivedPerson,
     [x in received._correspAction WHERE x._type="date"][0] as receivedDate,
     [x in received._correspAction WHERE x._type="placeName"][0] as receivedPlaceName
CREATE (c:Com {cId:correspDesc.key, source:correspDesc.source, sentPersonName:sentPerson._text, sentPersonId:sentPerson.ref, sentDateWhen:sentDate.when, sentDateNotBefore:sentDate.notBefore, sentDateNotAfter:sentDate.notAfter, sentDateCert:sentDate.cert, sentPlaceName:sentPlaceName._text, sentPlaceNameRef:sentPlaceName.ref, sentPlaceNameEvidence:sentPlaceName.evidence,
receivedPersonName:receivedPerson._text, receivedPersonId:receivedPerson.ref, receivedDateWhen:receivedDate.when, receivedDateNotBefore:receivedDate.notBefore, receivedDateNotAfter:receivedDate.notAfter, receivedDateCert:receivedDate.cert, receivedPlaceName:receivedPlaceName._text, receivedPlaceNameRef:receivedPlaceName.ref, receivedPlaceNameEvidence:receivedPlaceName.evidence});


// Personen erstellen
match (c:Com)
where c.sentPersonId IS NOT NULL
merge (p:Person {gnd:c.sentPersonId});
match (c:Com)
where c.receivedPersonId IS NOT NULL
merge (p:Person {gnd:c.receivedPersonId});
match (c:Com)
where c.receivedPersonId IS NULL
and c.receivedPersonName IS NOT NULL
merge (p:Person {label:c.receivedPersonName});
match (c:Com)
where c.sentPersonId IS NULL
and c.sentPersonName IS NOT NULL
merge (p:Person {label:c.sentPersonName});

match (c:Com), (p:Person)
where c.receivedPersonId = p.gnd
set p.label = c.receivedPersonName;
match (c:Com), (p:Person)
where p.label IS NULL
and c.sentPersonId = p.gnd
set p.label = c.sentPersonName;

// Letter erstellen
match (c:Com)
match (s:Person {gnd:c.sentPersonId})
match (r:Person {gnd:c.receivedPersonId})
create (s)<-[:SENDER]-(l:Letter {
sentDateNotAfter:c.sentDateNotAfter,
sentDateNotBefore:c.sentDateNotBefore,
sentDateWhen:c.sentDateWhen, date:c.sentDateWhen})-[:RECEIVER]->(r)
with c,l
where c.sentPlaceNameRef IS NOT NULL
merge (p:Place {geonames:c.sentPlaceNameRef,  label:c.sentPlaceName})
merge (p)<-[:SENT_PLACE]-(l)
with c,l
where c.receivedPlaceNameRef IS NOT NULL
merge (p:Place {geonames:c.receivedPlaceNameRef,  label:c.receivedPlaceName})
merge (p)<-[:RECEIVED_PLACE]-(l);

// Letterdate ergänzen
match (l:Letter) where l.date IS NULL and l.sentDateNotBefore IS NOT NULL
set l.date = l.sentDateNotBefore;
match (l:Letter) where l.date IS NULL and l.sentDateNotAfter IS NOT NULL and l.sentDateNotBefore IS NULL
set l.date = l.sentDateNotAfter;
~~~

# Graphergänzung zu vorhandenen Entityknoten

In der Graphdatenbank sind schon Knoten enthalten, die die WikidataId in der Property wikidataId enthalten. Mit dem folgenden Query werden alle Person-Knoten abgefragt und dann die oben aufgelisteten informationen aus Wikidata abgefragt und anschließend in der neo4j-DB gespeichert. Die erste Liste enthält Infos, die als Properties der Knoten angelegt werden.


~~~cypher
// Alle Persons mit WikidataId (Kein \n SPARQL Query !)
WITH [
// alles was hier steht wird als Property eines Knotens angelegt
"http://www.wikidata.org/entity/P21", // sex or gender
"http://www.wikidata.org/entity/P509", // cause of death
"http://www.wikidata.org/entity/P569", // date of birth
"http://www.wikidata.org/entity/P570", // date of death
"https://www.wikidata.org/entity/P735", // given name
"https://www.wikidata.org/entity/P734" // familiy name
]
as propertyEntities, [
// alles was hier steht wird als Knoten angelegt und verknüpft
"http://www.wikidata.org/entity/P361", // part of
"http://www.wikidata.org/entity/P39", // position held
"http://www.wikidata.org/entity/P106", // social classification
"http://www.wikidata.org/entity/P53", // family
"http://www.wikidata.org/entity/P3373", // sibling
"http://www.wikidata.org/entity/P1038", // relative
"http://www.wikidata.org/entity/P21", // sex or gender
"http://www.wikidata.org/entity/P31", // is instance of
"http://www.wikidata.org/entity/P463", // member of
"http://www.wikidata.org/entity/P26", // spouse of
"http://www.wikidata.org/entity/P40", // child of
"http://www.wikidata.org/entity/P22", // father of
"http://www.wikidata.org/entity/P25", // mother of
"http://www.wikidata.org/entity/P6" // head of governmant
]
as relationshipResults
MATCH (p:Person) WHERE p.wikidataId is not null
WITH p.wikidataId AS wikidataId, propertyEntities, relationshipResults
// SPARQL-Query darf keine Zeilenwechsel enthalten, da der Wikidata Query Service sonst einen Fehler meldet.
WITH apoc.text.urlencode(" SELECT ?wd ?wdLabel ?ps ?ps_Label ?ps_ ?wdpq ?wdpqLabel ?pq ?pq_Label { VALUES (?company) {(wd:" + wikidataId + ")} ?company ?p ?statement . ?statement ?ps ?ps_ .  ?wd wikibase:claim ?p. ?wd wikibase:statementProperty ?ps. OPTIONAL { ?statement ?pq ?pq_ . ?wdpq wikibase:qualifier ?pq . } SERVICE wikibase:label { bd:serviceParam wikibase:language \"en\" } } ORDER BY ?wd ?statement ?ps")
  AS sparql, wikidataId, propertyEntities, relationshipResults
CALL apoc.load.jsonParams(
  "https://query.wikidata.org/sparql?query=" + sparql,
  { Accept: "application/sparql-results+json"},
  null
)
YIELD value
WITH value.results.bindings AS all, wikidataId, propertyEntities, relationshipResults
MERGE (subject:Person{wikidataId: wikidataId})
SET subject += apoc.map.fromPairs([x in all WHERE x.wd.value in propertyEntities| [apoc.text.camelCase(x.wdLabel.value), x.ps_Label.value]])
WITH subject, all, propertyEntities, relationshipResults
UNWIND all AS rel
WITH rel,subject 
WHERE rel.wd.value in relationshipResults 
AND rel.ps_Label.value IS NOT NULL
CALL apoc.merge.node(["Wikidata"], {wikidataId:rel.ps_.value}, {label:rel.ps_Label.value, pUrl:rel.ps.value, pLabel:rel.wdLabel.value}, {source:'wikidata'}) YIELD node as wikiNode
CALL apoc.merge.relationship(subject, toUpper(rel.wdLabel.value), {}, apoc.map.fromLists([rel.wdpqLabel.value],[rel.pq_Label.value]), wikiNode) yield rel as rel2
return subject, wikiNode, rel2;
~~~

### Ergänzung der WikidataId aus vorhandener gndId

~~~
// mit GND Wikidata ergänzen
MATCH (p:Entity) WHERE p.gndId IS NOT NULL
AND p.wikidataId IS NULL
WITH p.gndId AS gndId
WITH 'SELECT ?item ?itemLabel
WHERE
{
?item wdt:P227 "' + gndId + '" .
SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
}'
AS sparql, gndId
CALL apoc.load.jsonParams("https://query.wikidata.org/sparql?query=" + apoc.text.urlencode(sparql),
{ Accept: "application/sparql-results+json"},
null
)
YIELD value
with value.results.bindings as a, gndId
unwind a as item
match (p:Entity {gndId:gndId})
set p.wikidataId = substring(item.item.value, 31)
set p.wikidataUrl = item.item.value
return substring(item.item.value, 31), gndId, p.label;
~~~
