---
title: Tipps und Tricks
layout: default
order: 45
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

Der Befehl hierzu sieht wie folgt auch:

~~~cypher
MATCH (p:Person)
FOREACH ( j in split(p.abschluss, ", ") |
MERGE (t:Titel {name:j})
MERGE (t)<-[:ABSCHLUSS]-(p)
);
~~~

Zu beachten ist, dass die im CSV-Feld gemeinsam genannten Begriffe keine konsistent benannt sein müssen.

# Die Apoc-Bibliothek

Die Funktionalitäten sind bei neo4j in verschiedene Bereiche aufgeteilt. Die Datenbank selbst bringt Grundfunktionalitäten mit. Um Industriestandards zu genügen haben diese Funktionen umfangreiche Tests und Prüfungen durchlaufen. Weiteregehende Funktionen sind in die sogenannte [*apoc-Bibliothek*](https://guides.neo4j.com/apoc) ausgelagert, die zusätzlich installiert werden muss. Diese sogenannten *user defined procedures* sind benutzerdefinierte Implementierungen bestimmter Funktionen, die in cypher selbst nicht so leicht ausgedrückt werden können. Diese Prozeduren sind in Java implementiert und können einfach in Ihre Neo4j-Instanz implementiert und dann direkt von Cypher aus aufgerufen werden.[^5cb9]

Die APOC-Bibliothek besteht aus vielen Prozeduren, die bei verschiedenen Aufgaben in Bereichen wie Datenintegration, Graphenalgorithmen oder Datenkonvertierung helfen.

Die Apoc-Bibliothek lässt sich unter http://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/%7Bapoc-release%7D herunterladen und muss in den plugin-Ordner der neo4j-Datenbank kopiert werden. Nach dem Neustart der Datenbank stehen die zusätzlichen Funktionen zur Verfügung. Mit folgendem Befehl kann überprüft werden, ob die Apoc-Bibliotheken installiert sind:

CALL dbms.functions()

Wenn eine Liste mit Funktionen ausgegeben wird, war die Installation erfolgreich. Falls nicht, sollte die Datenbank nochmals neu gestartet werden.

In neo4j-Desktop kann die Apoc-Bibliothek jeweils pro Datenbank im Management-Bereich über den Reiter plugins per Mausklick installiert werden.

[^5cb9]: Vgl. https://guides.neo4j.com/apoc (zuletzt aufgerufen am 11.04.2018).
