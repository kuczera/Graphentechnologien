---
title: Cypher für Fortgeschrittene
layout: default
order: 85
contents: true
---

# Inhalt
{:.no_toc}

* Will be replaced with the ToC, excluding the "Contents" header
{:toc}

# cypher-Dokumentation

Die Dokumentation von cypher findet sich auf den Seiten von neo4j:
[https://neo4j.com/docs/developer-manual/current/](https://neo4j.com/docs/developer-manual/current/)

# Analyse der Graphdaten

## Welche und jeweils wieviele Knoten enthält die Datenbank

Mit dem folgenden Query werden alle Typen von Knoten und deren jeweilige Häufigkeit aufgelistet.

~~~cypher
CALL db.labels()
YIELD label
CALL apoc.cypher.run("MATCH (:`"+label+"`)
RETURN count(*) as count", null)
YIELD value
RETURN label, value.count as count
ORDER BY label
~~~

## Welche Verknüpfungen gibt es in der Datenbank und wie häufig sind sie

~~~cyper
CALL db.relationshipTypes()
YIELD relationshipType
CALL apoc.cypher.run("MATCH ()-[:" + `relationshipType` + "]->()
RETURN count(*) as count", null)
YIELD value
RETURN relationshipType, value.count AS count
ORDER BY relationshipType
~~~

# Weitere Labels für einen Knoten

Gegeben sind Knoten vom Typ IndexEntry, die in der Property type noch näher spezifiziert sind (z.B. Ort, Person, Sache etc.).
Mit dem folgenden Query wird der Wert der Proptery type als zusätzliches Label angelegt.

~~~cypher
MATCH (e:IndexEntry)
WHERE e.type IS NOT NULL
WITH e, e.type AS label
CALL apoc.create.addLabels(id(e), [label]) YIELD node
RETURN node;
~~~

Die Namen der Labels können auch selbst bestimmt werden.

~~~cypher
MATCH (e:IndexEntry)
WHERE e.type = 'person'
WITH e
CALL apoc.create.addLabels(id(e), ['IndexPerson']) YIELD node
RETURN node;

MATCH (e:IndexEntry)
WHERE e.type = 'ereignis'
WITH e
CALL apoc.create.addLabels(id(e), ['IndexEvent']) YIELD node
RETURN node;

MATCH (e:IndexEntry)
WHERE e.type = 'sache'
WITH e
CALL apoc.create.addLabels(id(e), ['IndexThing']) YIELD node
RETURN node;

MATCH (e:IndexEntry)
WHERE e.type = 'ort'
WITH e
CALL apoc.create.addLabels(id(e), ['IndexPlace']) YIELD node
RETURN node;
~~~


# CSV-Feld enthält mehrere Werte

Beim Import von Daten im CSV-Format in die Graphdatenbank kann es vorkommen, dass in einem CSV-Feld mehrere Werte zusammen stehen. In diesem Abschnitt wird erklärt, wie man diese Werte auseinandernehmen, einzeln im Rahmen des Imports nutzen kann.

In der Regel ist es von Vorteil, zunächst das CSV-Feld als eine Propery zu importieren und in einem zweiten Schritt auseinanderzunehmen.

Angenommen wir haben Personen importiert, die in der Property `abschluss` eine kommaseparierte Liste von verschiedenen beruflichen Abschlüssen haben, wie z.B. Lehre, BA-Abschluss, MA-Abschluss, Promotion.

In der Property `abschluss` steht zum Beispiel drin:

`lic. theol., mag. art., dr. theol., bacc. art., bacc. bibl. theol.`

Für die Aufteilung der Einzelwerte kann die `split`-Funktion verwendet werden, die einen String jeweils an einem anzugebenden Schlüsselzeichen (hier das Komma) auftrennt. Der Befehl hierzu sieht wie folgt auch:

~~~cypher
MATCH (p:Person)
FOREACH ( j in split(p.abschluss, ", ") |
MERGE (t:Titel {name:j})
MERGE (t)<-[:ABSCHLUSS]-(p)
);
~~~

Der Query nimmt die Liste von Abschlüssen jeweils beim Komma auseinander, erstellt mit dem `MERGE`-Befehl einen Knoten für den Abschluss (falls noch nicht vorhanden) und verlinkt diesen Knoten dann mit dem Personenknoten.
Zu beachten ist, dass die im CSV-Feld gemeinsam genannten Begriffe konsistent benannt sein müssen.

# Regluäre Ausdrücke

Mit Apoc ist es möglich, reguläre Ausrücke zum Auffinden und Ändern von Property-Werten zu nutzen.

Mit dem folgenden Query werden in den Überlieferungsteilen der Regesten Kaiser Heinrichs IV. die Verlinkungen der Litereratur rausgesucht und für jeden Link per MERGE ein Knoten erzeugt. Anschließend werden die neu erstellen Knoten mit den jeweiligen Regesten über eine `REFERENCES`-Kante verbunden.

~~~cypher
MATCH (reg:Regesta)
WHERE reg.archivalHistory CONTAINS "link"
UNWIND apoc.text.regexGroups(reg.archivalHistory, "<link (\\S+)>(\\S+)</link>") as link
MERGE (ref:Reference {url:link[1]}) ON CREATE SET ref.title=link[2]
MERGE (reg)-[:REFERENCES]->(ref);
~~~

<<<<<<< HEAD


=======
>>>>>>> 0ced1e51a822a7e4d6adce8e50b12c19a823f258
# `MERGE` schlägt fehl da eine Property NULL ist

Der `MERGE`-Befehl entspricht in der Syntax dem `CREATE`-Befehl, überprüft aber bei jedem Aufruf, ob der zu erstellende Knoten bereits in der Datenbank existiert. Bei dieser Überprüfung werden alle Propertys des Knoten überprüft. Falls also ein vorhandener Knoten eine Property nicht enthält, wird ein weiterer Knoten erstellt. Umgekehrt endet der `MERGE`-Befehl mit einer Fehlermeldung, wenn eine der zu prüfenden Propertys NULL ist.

Gerade beim Import von CSV-Daten leistet der `MERGE`-Befehl in der Regel sehr gute Dienste, da man mit ihm bereits beim Import einer Tabelle weitere Knotentypen anlegen und verlinken kann. Oft kommt es aber vor, dass man sich nicht sicher ist, ob eine entsprechende Property in allen Fällen existiert. Hier bietet es sich an, vor dem `MERGE`-Befehl mit einer `WHERE`-Clause die Existenz der Property zu überprüfen.

Im folgenden Beispiel importierten wir Personen aus einer CSV-Liste, bei denen pro Person jeweils eine ID, ein Name und manchmal ein Herkunftsort angegeben ist. Im ersten Schritt werden im `CREATE`-Statement die Personen erstellt und auch der Herkunftsort als Property angelegt, der aber auch NULL sein kann.

~~~cypher
LOAD CSV WITH HEADERS FROM "file:///import.csv" AS line
CREATE (p:Person {pid:line.ID_Person, name:line.Name, herkunft:line.Herkunft});
~~~

Im zweiten Schritt wird nun der `LOAD CSV`-Befehl nochmals ausgeführt und über die `WHERE`-Clause nur jene Fälle weiter bearbeitet, in denen die Property Herkunft nicht NULL ist. Nach der `WHERE`-Clause wird über den `MATCH`-Befehl zunächst der passende Personenknoten aufgerufen, anschließend per `MERGE`-Befehl der Ortsknoten erstellt (falls noch nicht vorhanden) und schließlich mit `MERGE` beide verknüpft.

~~~cypher
LOAD CSV WITH HEADERS FROM "file:///import.csv" AS line
WHERE line.Herkunft IS NOT NULL
MATCH (p:Person {pid:line.ID_Person})
MERGE (o:Ort {ortsname:line.Herkunft})
MERGE (p)-[:HERKUNFT]->(o);
~~~

# Knoten hat bestimmte Kante nicht

Am Beispiel der [Regesta-Imperii-Graphdatenbank](http://134.176.70.65:10210/browser/) der Regesten Kaiser Friedrichs III. werden mit dem folgenden Cypher-Query alle Regestenknoten ausgegeben, die keine `PLACE_OF_ISSUE`-Kante zu einem `Place`-Knoten haben:

~~~cypher
MATCH (reg:Regesta)
WHERE NOT
(reg)-[:PLACE_OF_ISSUE]->(:Place)
RETURN reg;
~~~

# Häufigkeit von Wortketten

Am Beispiel des [DTA-Imports](http://134.176.70.65:10220/browser/) von [Berg Ostasien](http://www.deutschestextarchiv.de/book/show/berg_ostasien01_1864) wird mit dem folgenden Query die Häufigkeit von Wortketten im Text ausgegeben:

~~~cypher
MATCH p=(n1:Token)-[:NEXT_TOKEN]->(n2:Token)-[:NEXT_TOKEN]->(n3:Token)
WITH n1.text as text1, n2.text as text2, n3.text as text3, count(*) as count
WHERE count > 1 // evtl höherer Wert hier
RETURN text1, text2, text3, count ORDER BY count DESC LIMIT 10
~~~

# Der `WITH`-Befehl

Da cypher eine deklarative und keine imperative Sprache ist gibt es bei der Formulierung der Querys Einschränkungen.[^03a5] Hier hilft oft der `WITH`-Befehl weiter, mit dem sich die o.a. beiden Befehle auch in einem Query vereinen lassen:

~~~cypher
LOAD CSV WITH HEADERS FROM "file:///import.csv" AS line
CREATE (p:Person {pid:line.ID_Person, name:line.Name, herkunft:line.Herkunft})
WITH line, p
WHERE line.Herkunft IS NOT NULL
MERGE (o:Ort {ortsname:line.Herkunft})
MERGE (p)-[:HERKUNFT]->(o);
~~~

Der `LOAD CSV`-Befehl lädt die CSV-Datei und gibt sie zeilenweise an den `CREATE`-Befehl weiter. Dieser erstellt den Personenknoten. Der folgende `WITH`-Befehl stellt quasi alles wieder auf Anfang und gibt an die nach ihm kommenden Befehle nur die Variablen line und p weiter.

# Die Apoc-Bibliothek

Die Funktionalitäten sind bei neo4j in verschiedene Bereiche aufgeteilt. Die Datenbank selbst bringt Grundfunktionalitäten mit. Um Industriestandards zu genügen haben diese Funktionen umfangreiche Tests und Prüfungen durchlaufen. Weiteregehende Funktionen sind in die sogenannte [*apoc-Bibliothek*](https://guides.neo4j.com/apoc) ausgelagert, die zusätzlich installiert werden muss. Diese sogenannten *user defined procedures* sind benutzerdefinierte Implementierungen bestimmter Funktionen, die in cypher selbst nicht so leicht ausgedrückt werden können. Diese Prozeduren sind in Java implementiert und können einfach in Ihre Neo4j-Instanz implementiert und dann direkt von Cypher aus aufgerufen werden.[^5cb9]

Die APOC-Bibliothek besteht aus vielen Prozeduren, die bei verschiedenen Aufgaben in Bereichen wie Datenintegration, Graphenalgorithmen oder Datenkonvertierung helfen.

## Installation in neo4j

Die Apoc-Bibliothek lässt sich unter [http://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/%7Bapoc-release%7D](http://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/%7Bapoc-release%7D) herunterladen und muss in den plugin-Ordner der neo4j-Datenbank kopiert werden.

## Installation unter neo4j-Desktop

In [*neo4j-Desktop*](https://neo4j.com/download/) kann die Apoc-Bibliothek jeweils pro Datenbank im Management-Bereich über den Reiter plugins per Mausklick installiert werden.

![Installation der apoc-Bibliothek in neo4j-Desktop](Bilder/cypherFortgeschrittene/neo4j-Desktop-install-apoc.png)

## Liste aller Funktionen

Nach dem Neustart der Datenbank stehen die zusätzlichen Funktionen zur Verfügung. Mit folgendem Befehl kann überprüft werden, ob die Apoc-Bibliotheken installiert sind:

CALL dbms.functions()

Wenn eine Liste mit Funktionen ausgegeben wird, war die Installation erfolgreich. Falls nicht, sollte die Datenbank nochmals neu gestartet werden.

## Dokumentation aller Funktionen

In der [Dokumentation](https://neo4j-contrib.github.io/neo4j-apoc-procedures/) der apoc-Bibliothek sind die einzelnen Funktionen genauer beschrieben.

# apoc.xml.import

Mit dem Befehl apoc.xml.import ist es möglich, einen xml-Baum 1:1 in die Graphdatenbank einzuspielen.[^81c5] Darüber hinaus werden mit dem Die [Dokumentation](https://neo4j-contrib.github.io/neo4j-apoc-procedures/#_import_xml_directly) findet sich [hier](https://neo4j-contrib.github.io/neo4j-apoc-procedures/#_import_xml_directly).

Beispielbefehl:
call
apoc.xml.import("URL",{createNextWordRelationships:
true})
yield node
return node;


|Kantentyp|Beschreibung|
|---------|------------|
|:IS_CHILD_OF|Verweis auf eingeschachteltes Xml-Element|
|:FIRST_CHILD_OF|Verweis auf das erste untergeordnete Element|
|:NEXT_SIBLING|Verweis auf das nächste Xml-Element auf der gleichen Ebene|
|:NEXT|Erzeugt eine lineare Kette durch das gesamte XML-Dokument und gibt so die Serialität des XMLs wieder|
|:NEXT_WORD|Verbindet Wortknoten zu einer Kette von Wortknoten. Wird nur erzeugt, wenn createNextWordRelationships:true gesetzt wird|


# (apoc.load.json)

(Dieser Abschnitt befindet sich gerade in Bearbeitung)

~~~cypher
create constraint on (p:Person) assert p.id is unique;
create constraint on (p:AristWork) assert p.id is unique;
create constraint on (p:Manuscript) assert p.id is unique;

call apoc.load.json("file:///var/lib/neo4j/import/cagb-graph-test-v1.json") yield value
unwind keys(value.persons) as personId
merge (personNode:Person{id:personId})
set personNode = value.persons[personId];

call apoc.load.json("file:///var/lib/neo4j/import/cagb-graph-test-v1.json") yield value
unwind keys(value.aristWorks) as aristWorksId
merge (aristWorksNode:AristWork{id:aristWorksId})
set aristWorksNode = value.aristWorks[aristWorksId];

call apoc.load.json("file:///var/lib/neo4j/import/cagb-graph-test-v1.json") yield value
unwind keys(value.mss) as msId
merge (msNode:Manuscript{id:msId})
set msNode = value.mss[msId];

call apoc.load.json("file:///var/lib/neo4j/import/cagb-graph-test-v1.json") yield value
unwind value.`ms-person-rel` as rel
match (start:Person{id:rel.person})
match (end:Manuscript{id:rel.ms})
with start, end, rel
call apoc.merge.relationship(start, toUpper(rel.rel), {}, {}, end) yield rel as dummy
return count(*);

call apoc.load.json("file:///var/lib/neo4j/import/cagb-graph-test-v1.json") yield value
unwind value.`ms-ms-rel` as rel
merge (start:Manuscript{id:rel.ms})
merge (end:Manuscript{id:rel.`other-ms`})
with start, end, rel
call apoc.merge.relationship(start, toUpper(rel.rel), {}, {}, end) yield rel as dummy
return count(*);

call apoc.load.json("file:///var/lib/neo4j/import/cagb-graph-test-v1.json") yield value
unwind value.`ms-aristWork-rel` as rel
match (start:Manuscript{id:rel.ms})
match (end:AristWork{id:rel.aristWork})
with start, end, rel
call apoc.merge.relationship(start, toUpper(rel.rel), {}, {}, end) yield rel as dummy
return count(*);
~~~

json-example

~~~
{
  "mspersonrel": [{
    "ms": "69686",
    "person": "d3f1",
    "rel": "author-contained"
  }, {
    "ms": "69686",
    "person": "p3366450e-0387-43d4-9f04-7f0f1c08dff8",
    "rel": "scribe"
  }, {
    "ms": "69686",
    "person": "p8c827441-77b4-4e12-8209-7ce8f06060f1",
    "rel": "scribe"
  }
  ],
  "persons": {
    "d19f17": {
      "label": "Castro, Juan Pàez de",
      "id": "d19f17"
    },
    "d10f30": {
      "label": "Augustinus (Aurelius Augustinus)",
      "id": "d10f30"
    },
    "d22f20": {
      "label": "Manouel\n Chrysoloras",
      "id": "d22f20"
    }
  },
  "aristWorks": {
    "EE": {
      "label": "Ethica ad Eudemum (EE)",
      "id": "EE"
    },
    "Parva-Naturalia": {
      "label": "Parva naturalia (Parva Naturalia)",
      "id": "Parva-Naturalia"
    },
    "Hist.-An.": {
      "label": "Historia animalium (Hist. An.)",
      "id": "Hist.-An."
    }
  }

~~~

[^5cb9]: Vgl. https://guides.neo4j.com/apoc (zuletzt aufgerufen am 11.04.2018).

[^03a5]: Hierzu vgl. https://de.wikipedia.org/wiki/Deklarative_Programmierung zuletzt abgerufen am 12.6.2018.

[^81c5]: Zu diesem Abschnitt vgl. [https://neo4j-contrib.github.io/neo4j-apoc-procedures/#_import_xml_directly](https://neo4j-contrib.github.io/neo4j-apoc-procedures/#_import_xml_directly). Die Tabelle ist direkt übernommen und übersetzt worden. Die dort genannte Beispieldatei ist momentan nicht mehr erreichbar. Stattdessen kann folgende URL verwendet werden: https://seafile.rlp.net/f/55e80fc426fb451e9294/?dl=1
