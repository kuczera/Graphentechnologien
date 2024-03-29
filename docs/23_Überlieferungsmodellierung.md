---
title: Überlieferungsmodellierung bei den Regesta Imperii
layout: default
order: 23
contents: true
---

# Überlieferungsmodellierung bei den Regesta Imperii

(Dieser Abschnitt befindet sich in Bearbeitung)

# Inhalt
{:.no_toc}

* Will be replaced with the ToC, excluding the "Contents" header
{:toc}

## Eine Urkunde, viele Regesten oder: Was ist das Problem ?

### Alles eine Frage der Überlieferung

Aufmerksame Leser der Regesten werden im Abschnitt zu Überlieferung und Literatur hin und wieder auf die Aussage "Ein ausführliches Regest bieten die Regg.F.III. H. 2 n. 129; s. ferner dass. H. 3 n. 110; H. 4 n. 543 ..." gestoßen sein, wie hier in diesem [Beispielregest](http://www.regesta-imperii.de/id/a706627c-0a88-4698-8182-f0b602800757) zu sehen.
Hintergrund dieser Hinweise ist die Überlieferungsgeschichte der Urkunden. Im Projekt zu den Regesten Kaiser Friedrichs III. werden jeweils Archivlandschaften in einem Regestenheft behandelt. Dabei kann es vorkommen, dass eine Urkunde als Abschrift aufgefunden wird, das Original bisher aber noch nicht bekannt ist. Folglich wird dann auf Grundlage dieser Abschrift ein ausführliches Regest erstellt. Taucht dann im weiteren Arbeitsprozess in einem anderen Archiv eine weitere Abschrift oder sogar das Original auf, verweisen diese in der Regel auf das erste ausführliche Regest und halten das neue Regest entsprechend knapp. Enthält das Original oder die weitere Kopie allerdings relevante neue Informationen, wird ein neues ausführliches Regest, auch hier unter Verweis auf das Ausführliche, erstellt.

### Regesten oder Urkunden zählen ?

Die o.a. Arbeitsweise führt dazu, dass es zu einem in einer Urkunde festgehaltenen Rechtsakt durchaus mehrere Regesten geben kann. Dient nun die Anzahl der Regesten eines Herrschers als Grundlage für statistische Überlegungen zu seinem Urkundenverhalten, kann dies die Zahlen und die daraus aufbauenden statistischen Aussagen verfälschen.

~~~cypher
// SAME_AS-Kanten erstellen
MATCH (reg:Regesta)
WHERE reg.archivalHistory CONTAINS "link"
AND reg.archivalHistory CONTAINS "ausführliches Regest"
UNWIND apoc.text.regexGroups(reg.archivalHistory,
"<link reg:(\\S*?)>(.*?)</link>") as link
MATCH (r2:Regesta {regid:link[1]})
CREATE (reg)-[:SAME_AS {type:'ein_ausführliches_Regest_bietet'}]->(r2);
~~~



![Visualisierung von sameAs-Beziehungen](Bilder/sameAsRegesta/samaAs.png)
