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

# Mehrere Werte in einem CSV-Feld importieren

Beim Import von Daten im CSV-Format in die Graphdatenbank kann es vorkommen, dass in einem CSV-Feld mehrere werte zusammen stehen. In diesem Abschnitt wird erklärt, wie man diese Werte auseinandernehmen, einzeln als Knoten anlegen und verknüpfen kann.

In der Regel ist es von Vorteil, zunächst das CSV-Feld als eine Propery zu importieren und in einem zweiten Schritt auseinanderzunehmen.

Angenommen wir haben Personen importiert, die in der Property `abschluss` eine kommaseparierte Liste von verschiedenen beruflichen Abschlüssen haben, wie z.B. Lehre, BA-Abschluss, MA-Abschluss, Promotion.

In der Property `abschluss` steht zum Beispiel drin:

`lic. theol., mag. art., dr. theol., bacc. art., bacc. bibl. theol.`

Der Befehl hierzu sieht wie folgt auch:

~~~cypher
MATCH (p:Person)
FOREACH ( j in split(p.abschluss, ", ") |
MERGE (t:Titel {name:j})
MERGE (t)<-[:ABSCHLUSS]-(p)
);
~~~

Der Query nimmt die Liste von Abschlüssen jeweils beim Komma auseinander, erstellt mit dem `MERGE`-Befehl einen Knoten für den Abschluss (falls noch nicht vorhanden) und verlinkt diesen Knoten dann mit dem Personenknoten.
Zu beachten ist, dass die im CSV-Feld gemeinsam genannten Begriffe konsistent benannt sein müssen.

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

# apoc.load.xml

Mit dem Befehl apoc.load.xml ist es möglich, einen xml-Baum 1:1 in die Graphdatenbank einzuspielen.[^81c5]


|Kantentyp|Beschreibung|
|---------|------------|
|:IS_CHILD_OF|Verweis auf eingeschachteltes Xml-Element|
|:FIRST_CHILD_OF|Verweis auf das erste untergeordnete Element|
|:NEXT_SIBLING|Verweis auf das nächste Xml-Element auf der gleichen Ebene|
|:NEXT|Erzeugt eine lineare Kette durch das gesamte XML-Dokument und gibt so die Serialität des XMLs wieder|
|:NEXT_WORD|Verbindet Wortknoten zu einer Kette von Wortknoten. Wird nur erzeugt, wenn createNextWordRelationships:true gesetzt wird|



[^5cb9]: Vgl. https://guides.neo4j.com/apoc (zuletzt aufgerufen am 11.04.2018).

[^03a5]: Hierzu vgl. https://de.wikipedia.org/wiki/Deklarative_Programmierung zuletzt abgerufen am 12.6.2018.

[^81c5]: Zu diesem Abschnitt vgl. [https://neo4j-contrib.github.io/neo4j-apoc-procedures/#_import_xml_directly](https://neo4j-contrib.github.io/neo4j-apoc-procedures/#_import_xml_directly). Die Tabelle ist direkt übernommen und übersetzt worden. Die dort genannte Beispieldatei ist momentan nicht mehr erreichbar. Stattdessen kann folgende URL verwendet werden: https://seafile.rlp.net/f/55e80fc426fb451e9294/?dl=1