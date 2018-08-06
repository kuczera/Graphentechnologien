---
title: Regestenmodellierung im Graphen
layout: default
order: 20
contents: true
---

# Inhalt
{:.no_toc}

* Will be replaced with the ToC, excluding the "Contents" header
{:toc}

# Wie kommen die Regesten in den Graphen ?

Die Regesta Imperii Online basieren momentan auf dem Content-Managment-System Typo3 welches auf eine mysql-Datenbank aufbaut. In der Datenbank werden die Regesteninformationen in verschiedenen Tabellen vorgehalten. Die Webseite bietet zum einen die Möglichkeit, die Regesten über eine REST-Schnittstelle im CEI-XML-Format oder als CSV-Dateien herunterzuladen. Für den Import in die Graphdatenbank bietet sich das CSV-Format an.

![Regesten als CSV-Datei](/Graphentechnologien/Bilder/RI2Graph/10-ods-regesten.png)

In der CSV-Datei finden sich die oben erläuterten einzelnen Elemente der Regesten in jeweils eigenen Spalten. Die Spaltenüberschrift gibt Auskunft zum Inhalt der jeweiligen Spalte.

## Import mit dem `LOAD CSV`-Befehl

Mit dem Befehl `LOAD CSV` können die CSV-Dateien mit den Regesten in die Graphdatenbank importiert werden.[^5147] Hierfür muss die Datenbank aber Zugriff auf die CSV-Daten haben. Dies ist einerseits über den im Datenbankverzeichnis vorhandene Ordner `import`  oder über eine URL auf die CSV-Datei möglich. Da sich die einzelnen Zugriffswege auf den `import`-Ordner von Betriebssystem zu Betriebssystem unterscheiden wird hier beispielhaft der Import mit einer URL vorgestellt. Hierfür wird ein Webserver benötigt, auf den man die CSV-Datei hochlädt und sich anschließend die Webadresse für den Download der Datei notiert.

## Google-Docs für den CSV-Download

Da viele aber keinen Zugriff auf einen eigenen Webserver haben wird hier auch der Download der CSV-Dateien über Google-Docs erklärt. Zunächst benötigt man hierfür einen Google-Account. Anschließend öffnet man Google-Drive und erstellt dort eine leere Google-Tabellen-Datei in der man dann die CSV-Datei hochladen und öffnen kann.

![Freigabe der Datei zum Ansehen für Dritte!](/Graphentechnologien/Bilder/RI2Graph/google-docs-freigeben.png)

Wichtig ist nun, die Datei zur Ansicht freizugeben (Klick auf `Freigeben` oben rechts im Fenster dann Link zum Freigeben abrufen und anschließend bestätigen). Jetzt ist die CSV-Datei in Google-Docs gespeichert und kann von Dritten angesehen werden. Für den Import in die Graphdatenbank benötigen wir aber einen Download im CSV-Format. Diesen findet man unter `Datei/Herunterladen als/Kommagetrennte Werte.csv aktuelles Tabellenblatt`.

![Herunterladen als CSV-DAtei](/Graphentechnologien/Bilder/RI2Graph/google-docs-herunterladen-csv.png)


Damit lädt man das aktuelle Tabellenblatt als CSV runter. Nach dem Download muss man nun im Browser unter Downloads den Download-Link der Datei suchen und kopieren.

![Download-Link der CSV-Datei](/Graphentechnologien/Bilder/RI2Graph/google-docs-link-kopieren.png)

## Die neo4j-Eingabezeile

Nachdem die Download-URL der CSV-Datei nun ermittelt ist, kann der `LOAD CSV`-Befehl angepasst und ausgeführt werden.

~~~cypher
// Regesten aus Google-Docs in die Graphdatenbank importieren
LOAD CSV WITH HEADERS FROM "https://docs.google.com/spreadsheets/d/1VCr1lSvVrcM-sFG0fLzNMawnBOd_WfqTq6eczMyNTQk/export?format=csv&id=1VCr1lSvVrcM-sFG0fLzNMawnBOd_WfqTq6eczMyNTQk&gid=1560491889" AS line
CREATE (r:Regesta {regId:line.persistent_identifier,
  text:line.summary, archivalHistory:line.archival_history,
  ident:line.identifier, origPlaceOfIssue:line.locality_string,
  startDate:line.start_date, endDate:line.end_date})
MERGE (d:Date {startDate:line.start_date,
  endDate:line.end_date})
MERGE (r)-[:HAS_DATE]->(d)
;
~~~

In den Anführungszeichen nach dem Befehl `LOAD CSV WITH HEADERS FROM` wird der Download-Link der CSV-Datei angegeben. Der `LOAD CSV`-Befehl lädt dann bei seiner Auführung die CSV-Datei von der angegebenen URL und gibt sie zeilenweise an die folgenden cyper-Befehle weiter.

![Blick auf die ersten Zeilen der Google-spreadsheets-Tabelle.](/Graphentechnologien/Bilder/RI2Graph/CSV-Google-Tabelle.png)

Mit dem `CREATE`-Befehl wird in der Graphdatenbank ein Knoten vom Typ Regestae erzeugt.[^336e] Diesem Knoten werden noch verschiedene Eigenschaften wie der Regestenidentifier, das Regest, die Überlieferung, die Datumsangabe und die Regestennummer mitgegeben. Wie dem Beispiel zu entnehmen ist, sind die Eigenschaften in CamelCase-Notation angegeben (z.B. archivalHistory).[^d219] Dies ist die hier übliche Notation, da Leerzeichen nicht verwendet werden dürfen und der Unterstrich je nach Betriebssystems Probleme verursachen kann. In der folgenden Tabelle sind die einzelnen Eigenschaften nochmal zusammengefasst und beispielhaft für das erste Regest aufgelistet.

|Eigenschaft|Spaltenüberschrift|Bedeutung|Wert
|:---------|--------|--------|:--------|
|`regid`|persistent_identifier|Ident des Regests|1050-11-11_1_0_3_2_3_1_1
|`text`|summary|Regestentext|Heinrich wird als viertes Kind Kaiser ...
|`archivalHistory`|archival_history|Überlieferung|Herim. Aug. 1050 ...
|`date`|date_string|Datumsangabe des Regests|1050 November 11
|`regnum`|regnum|Regestennummer innerhalb des Bandes|1

Der `CREATE`-Befehl bekommt über das Array line beim ersten Durchlauf die Zellen der ersten Zeile der CSV-Datei. Über line.regid kann dann auf den Wert der Spalte regid zugegriffen und dieser dann für die Erstellung der Eigenschaft regid verwendet werden. Auf die gleiche Weise werden dann auch die weiteren Eigenschaften des Regestenknotens erstellt.
In der folgenden Abbildung sind die Eigenschaften des Regestenknotens dargestellt.


![Die Eigenschaften des Regests, registerid, ident, Text regid und Überlieferung.](/Graphentechnologien/Bilder/RI2Graph/30-Regestentext.png)


In einer Zeile der CSV-Datei finden sich alle Angaben eines Regests. Die in der oben abgebildeten Tabelle angegebenen Werte werden als Eigenschaften des Regestenknotens erstellt.

In der nächsten Abbildung wird das Modell des Regests im Graphen abgebildet.

![ReggF3 Heft 19, Nr. 316.](/Graphentechnologien/Bilder/RI2Graph/ReggF3-H19-316.png)
![Das Regest im Graphen.](/Graphentechnologien/Bilder/RI2Graph/26-FIII-Regestengraph.png)

Die gelben Knoten sind die Regesten. Aus den Angaben des Regests werden mit dem o.a. Befehl noch ein Datumsknoten und ein Ortsknoten erstellt. Mit dem ersten `CREATE`-Befehl werden die Regesten erstellt. Mit den folgenden `MERGE`-Befehlen werden anschließend ergänzende Knoten für die Datumsangaben und die Ausstellungsorte erstellt. Nun ist es aber so, dass Ausstellungsort und Ausstellungsdatum mehrfach vorkommen können. Daher wird der hier nicht der `CREATE`-Befehl sondern der `MERGE`-Befehl verwendet. Dieser funktioniert wie der `CREATE`-Befehl, prüft aber vorher ob in der Datenbank ein solcher Knoten schon existiert. Falls es ihn noch nicht gibt wird er erzeugt, wenn es ihn schon gibt, wird er der entsprechenden Variable zugeordnet. Anschließend wird dann die Kante zwischen Regestenknoten und Ausstellungsortsknoten und Regestenknoten und Datumsknoten erstellt. In der folgenden Tabelle werden die einzelnen Befehle dargestellt und kommentiert.

|Befehl|Variablen|Bemerkungen|
|:--------|----------------|:----------------|
|`LOAD CSV WITH HEADERS FROM` "https://docs.google.com/ ..." AS line|line|Import der CSV-Dateien. Es wird jeweils eine Zeile an die Variable line weitergegeben|
|`CREATE` (r:Regest {regid:line.persistent_identifier, Text:line.summary, Überlieferung:line.archival_history,ident:line.identifier})|line.persistent_identifier, line.summary etc. |Erstellung des Regestenknotens. Für die weiteren Befehlt steht der neu erstellt Regestenknoten unter der Variable r zur Verfügung.|
|`MERGE` (d:Datum {startdate:line.start_date, enddate:line.end_date})|line.start_date und line.end_date|Es wird geprüft, ob ein Datumsknoten mit der Datumsangabe schon existiert, falls nicht, wird er erstellt. In jedem Fall steht anschließend der Datumsknoten unter der Variable d zur Verfügung.|
|`MERGE` (o:Ort {ort:line.name, latitude:toFloat(line.latitude), longitude:toFloat(line.longitude)})|line.name ist der Ortsname, die anderen Angaben sind die Geodaten des Ortes|Es wird geprüft, ob ein Ortsknoten schon existiert, falls nicht, wird er erstellt. In jedem Fall steht anschließend der Ortsknoten unter der Variable o zur Verfügung.|
|`MERGE` (r)-[:HAT_DATUM]->(d)|`(r)` ist der Regestenknoten, `(d)` ist der Datumsknoten|Zwischen Regestenknoten und Datumsknoten wird eine `HAT_DATUM`-Kante erstellt.|
|`MERGE` (r)-[:HAT_ORT]->(o);|`(r)` ist der Regestenknoten, `(o)` ist der Ortsknoten|Zwischen Regestenknoten und Ortsknoten wird eine `HAT_ORT`-Kante erstellt.|

# Import der Registerdaten in die Graphdatenbank

## Vorbereitung der Registerdaten

Register spielen für die Erschließung von gedrucktem Wissen eine zentrale Rolle, da dort in alphabetischer Ordnung die im Werk vorkommenden Entitäten (z.B. Personen und Orte) hierarchisch gegliedert aufgeschlüsselt werden. Für die digitale Erschließung der Regesta Imperii sind Register von zentraler Bedeutung, da mit ihnen die in den Regesten vorkommenden Personen und Orte bereits identifiziert vorliegen. Für den Import in die Graphdatenbank wird allerdings eine digitalisierterte Fassung des Registers benötigt. Im Digitalisierungsprojekt Regesta Imperii Online wurden Anfang der 2000er Jahre auch die gedruckt vorliegenden Register digitalisiert. Sie dienen nun als Grundlage für die digitale Registererschließung der Regesta Imperii. Im hier gezeigten Beispiel werden die Regesten Kaiser Heinrichs IV. und das dazugehörige Register importiert. Da der letzte Regestenband der Regesten Kaiser Heinrichs IV. mit dem Gesamtregister erst vor kurzem gedruckt wurde, liegen hier aktuelle digitale Fassung von Registern und Regesten vor. Die für den Druck in Word erstellte Registerfassung wird hierfür zunächst in eine hierarchisch gegliederte XML-Fassung konvertiert, damit die Registerhierarchie auch maschinenlesbar abgelegt ist.

![Ausschnitt aus dem XML-Register der Regesten Heinrichs IV.](/Graphentechnologien/Bilder/RI2Graph/XML-Register.png)

In der XML-Fassung sind die inhaltlichen Bereiche und die Abschnitte für die Regestennummern jeweils extra in die Tags `<Inhalt` und `Regestennummer` eingefasst. Innerhalb des Elements `Regestennummer` ist dann nochmal jede einzelne Regestennummer in `<r>`-Tags eingefasst. Die aus dem gedruckten Register übernommenen Verweise sind durch ein leeres `<vw/>`-Element gekennzeichnet.

Die in XML vorliegenden Registerdaten werden anschließend mit Hilfe von TuStep in einzelne CSV-Tabellen zerlegt.

![Ausschnitt der Entitätentabelle des Registers der Regesten Heinrichs IV.](/Graphentechnologien/Bilder/RI2Graph/RegisterH4-Tabelle-Entitäten.png)

In einer Tabelle werden alle Entitäten aufgelistet und jeweils mit einer ID versehen.

![Ausschnitt der Verknüpfungstabelle des Registers der Regesten Heinrichs IV.](/Graphentechnologien/Bilder/RI2Graph/RegisterH4-GENANNT.png)

In der anderen Tabelle werden die Verknüpfungen zwischen Registereinträgen und den Regesten aufgelistet. Der Registereintrag Adalbero kommt also in mehreren Regesten vor. Da das Register der Regesten Heinrichs IV. nur zwei Hierarchiestufen enthält, in denen beispielsweise verschiedene Amtsphasen ein und derselben Person unterschieden werden, wurden diese beim Import zusammengefasst.[^5979] Damit gibt es pro Person jeweils nur einen Knoten. In anderen Registern der Regesta Imperii sind teilweise fünf oder mehr Hierarchiestufen vorhanden, die jeweils auch Entitäten repräsentieren können. In diesen Fällen müssen die Hierarchien auch in der Graphdatenbank abgebildet werden, was durch zusätzliche Verweise auf die ggf. vorhandenen übergeordneten Registereinträge möglich wird.

![Ausschnitt der Entitätentabelle des Registers der Regesten Friedrichs III.](/Graphentechnologien/Bilder/RI2Graph/RegisterF3-Hierarchie.png)

Im Tabellenausschnitt wird jedem Registereintrag in der ersten Spalte eine `nodeID` zugewiesen. Wenn es sich um einen Registereintrag handelt, der kein Hauptlemma ist, wird in der dritten Spalte die `topnodeID` angegeben, die auf das übergeordnete Lemma verweist. Beim Import in die Graphdatenbank wird diese Hierarchie über `OBERBEGRIFF`-Kanten abgebildet, die vom untergeordneten Eintrag auf das übergeordnete Lemma verweisen. Damit ist die komplette Registerhierarchie im Graphen abgebildet. In der Spalte `name1` ist das Lemma angegeben, in der Spalte `name3` zusätzliche zum Lemma noch der gesamte Pfad vom Hauptlemma bis zum Registereintrag, jeweils auch `//` getrennt. Dies ist notwendig, da bei tiefer gestaffelten Registern allein mit der Angabe aus der Spalte `name1` nicht klar ist, zu welchem Oberbegriff beispielsweise die `Meierei` in Zeile 17 gehört. Mit dem kompletten Pfad des Registereintrages in der Spalte `name3` wird dagegen deutlich, dass die Aachener Meierei gemeint ist.

## Import in die Graphdatenbank

Im Gegensatz zu den Regesten Kaiser Friedrichs III., bei denen Orte und Personen in einem Register zusammengefasst sind, haben die Regesten Kaiser Heinrich IV. getrennte Orts- und Personenregister. Diese werden mit den folgenden cypher-Befehlen in die Graphdatenbank eingespielt.

~~~cypher
// Registereinträge Personen erstellen
LOAD CSV WITH HEADERS FROM "https://docs.google.com/spreadsheets/d/12T-RD1Ct4aAUNNNxipjMmHe9F1NmryI1gf8_SJ4RCEE/export?format=csv&id=12T-RD1Ct4aAUNNNxipjMmHe9F1NmryI1gf8_SJ4RCEE&gid=1167029283"
AS line
CREATE (:IndexPerson {registerId:line.ID, name1:line.name1});
~~~

~~~cypher
OAD CSV WITH HEADERS FROM "https://docs.google.com/spreadsheets/d/12T-RD1Ct4aAUNNNxipjMmHe9F1NmryI1gf8_SJ4RCEE/export?format=csv&id=12T-RD1Ct4aAUNNNxipjMmHe9F1NmryI1gf8_SJ4RCEE&gid=2049106817"
AS line
CREATE (:IndexPlace {registerId:line.ID, name1:line.name1});
~~~

Die beiden Befehle greifen auf verschiedene Tabellenblätter des gleichen Google-Tabellendokuments zu, laden es als CSV-Daten und übergeben die Daten zeilenweise an die `CREATE`-Befehle.
Im nächsten Schritt werden nun die Verknüpfungen zwischen den Registereinträgen und den Regesten erstellt.

~~~cypher
// PLACE_IN-Kanten für Orte erstellen
LOAD CSV WITH HEADERS FROM "https://docs.google.com/spreadsheets/d/12T-RD1Ct4aAUNNNxipjMmHe9F1NmryI1gf8_SJ4RCEE/export?format=csv&id=12T-RD1Ct4aAUNNNxipjMmHe9F1NmryI1gf8_SJ4RCEE&gid=2147130316"
AS line
MATCH (from:IndexPlace {registerId:line.ID}), (to:Regesta {regnum:line.regnum2})
CREATE (from)-[:PLACE_IN {regnum:line.regnum, name1:line.name1, name2:line.name2}]->(to);
~~~

~~~cypher
// PERSON_IN-Kanten für Person erstellen
LOAD CSV WITH HEADERS FROM "https://docs.google.com/spreadsheets/d/12T-RD1Ct4aAUNNNxipjMmHe9F1NmryI1gf8_SJ4RCEE/export?format=csv&id=12T-RD1Ct4aAUNNNxipjMmHe9F1NmryI1gf8_SJ4RCEE&gid=2147130316"
AS line
MATCH (from:IndexPerson {registerId:line.ID}), (to:Regesta {regnum:line.regnum2})
CREATE (from)-[:PERSON_IN {regnum:line.regnum, name1:line.name1, name2:line.name2}]->(to);
~~~


[^5147]: Verwendet wird die Graphdatenbank neo4j. Die Open-Source-Version ist kostenlos erhältlich unter [https://www.neo4j.com](https://www.neo4j.com).
[^892b]: Dies ist das Tabellenkalkulationsformat von Libreoffice und Openoffice. Vgl.  [https://de.libreoffice.org](https://de.libreoffice.org).

[^336e]: Die Angaben in der Graphdatenbank sind Englisch, daher *Regestae*.

[^d219]: Gemeint ist hier der lowerCamelCase bei dem der erste Buchstabe kleingeschrieben und dann jedes angesetzte Wort mit einem Großbuchstaben direkt angehängt (wie bei archivalHistory). Vgl. auch https://de.wikipedia.org/wiki/Binnenmajuskel#Programmiersprachen.

[^5979]: Vgl. die Vorbemerkung zum Register in Böhmer, J. F., Regesta Imperii III. Salisches Haus 1024-1125. Tl. 2: 1056-1125. 3. Abt.: Die Regesten des Kaiserreichs unter Heinrich IV. 1056 (1050) - 1106. 5. Lief.: Die Regesten Rudolfs von Rheinfelden, Hermanns von Salm und Konrads (III.). Verzeichnisse, Register, Addenda und Corrigenda, bearbeitet von Lubich, Gerhard unter Mitwirkung von Junker, Cathrin; Klocke, Lisa und Keller, Markus - Köln (u.a.) (2018), S. 291.

[^595c]: Vgl. Kuczera, Andreas; Schrade, Torsten: From Charter Data to Charter Presentation: Thinking about Web Usability in the Regesta Imperii Online. Vortrag auf der Tagung ›Digital Diplomatikcs 2013 – What ist Diplomatics in the Digital Environment?‹ Folien: https://prezi.com/vvacmdndthqg/from-charta-data-to-charta-presentation/.
[^0b8f]: Näheres dazu in Kuczera, Andreas: Digitale Perspektiven mediävistischer Quellenrecherche, in: Mittelalter. Interdisziplinäre Forschung und Rezeptionsgeschichte, 18.04.2014. URL: mittelalter.hypotheses.org/3492.

[^3273]: Vgl. beispielsweise Gramsch, Robert: Das Reich als Netzwerk der Fürsten - Politische Strukturen unter dem Doppelkönigtum Friedrichs II. und Heinrichs (VII.) 1225-1235. Ostfildern, 2013. Einen guten Überblick bietet das
Handbuch Historische Netzwerkforschung - Grundlagen und Anwendungen. Herausgegeben von
Marten Düring, Ulrich Eumann, Martin Stark und Linda von Keyserlingk. Berlin 2016.

[^ce4b]: Regesta chronologico-diplomatica Friderici III. Romanorum imperatoris (regis IV.) : Auszug aus den im K.K. Geheimen Haus-, Hof- und Staats-Archive zu Wien sich befindenden Registraturbüchern vom Jahre 1440 - 1493 ; nebst Auszügen aus Original-Urkunden, Manuscripten und Büchern / von Joseph Chmel, Wien 1838 und 1840.

[^6155]: Der cypher-Befehl zur Erstellung der 1zu1-Beziehungen lautet: *MATCH (n1:Registereintrag)-[:GENANNT_IN]->(r:Regest)<-[:GENANNT_IN]-(n2:Registereintrag)
MERGE (n1)-[:KNOWS]->(n2);* Dabei werden die gerichteten `KNOWS`-Kanten jeweils in beide Richtungen erstellt.
Mit folgendem Befehl lassen sich die `KNOWS`-Kanten zählen: *MATCH p=()-[r:KNOWS]->() RETURN count(p);* Für die Bestimmung der 1zu1-Beziehungen muss der Wert noch durch 2 geteilt werden.
