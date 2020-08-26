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

# Graphergänzung aus Wikidata

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
