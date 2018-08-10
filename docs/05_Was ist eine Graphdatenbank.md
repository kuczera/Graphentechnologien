---
title: Was ist eine Graphdatenbank
layout: default
order: 5
contents: true
---

# Inhalt
{:.no_toc}

* Will be replaced with the ToC, excluding the "Contents" header
{:toc}

# Was ist eine Graphdatenbank

In den seit den 70er Jahren etablierten, relationalen Datenbanken werden die Daten in Tabellen abgespeichert, die untereinander über Schlüssel oder Schlüsseltabellen verknüpft sind.
In Graphdatenbanken werden die Daten dagegen in Knoten und Kanten gespeichert.
![Beispielgraph](Bilder/Beispielgraph.png)

Der  zeigt oben einen <b>Knoten (engl. Nodes)</b>	vom Typ Person mit der Eigenschaft Name. Diese hat den Wert "Karl der Große". Links unten ist ein weiter <b>Knoten</b> vom Typ Person mit dem Namen "Einhard". Rechts unten ist ein <b>Knoten</b> vom Typ Buch und dem Titel "Vita Karoli Magni" abgebildet. Die <b>Kanten</b> (engl. Edges) geben an, dass Karl der Große Einhart kannte, Einhard ca. 828-830 das Buch "Vita Karoli Magni" schrieb und Karl der Große in dem Buch vorkommt.

Knoten und Kanten können also noch zusätzliche Eigenschaften besitzen, in denen weitere Informationen gespeichert sind. Diese Eigenschaften sind spezifisch für die jeweiligen Knotentypen. So sieht man in der Abbildung, dass die beiden Knoten vom Typ Person jeweils noch die Eigenschaft Namen haben, deren Wert dann die Namen der Person angibt, während der Knoten vom Typ Buch die Eigenschaft Titel trägt, in dem der Titel des Buches abgespeichert wird.

# Installation und Start

Informationen zur Installation von neo4j finden Sie auf den Dokumentationsseiten unter [https://neo4j.com/docs/operations-manual/current/installation/](https://neo4j.com/docs/operations-manual/current/installation/). Für den normalen Nutzer empfiehlt sich die Installation von [neo4j-Desktop](https://neo4j.com/download/).
