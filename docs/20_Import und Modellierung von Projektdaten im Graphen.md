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

![Regesten als CSV-Datei](/Graphentechnologien/Bilder/RI2Graph/ReggH4-Regestentabelle.png)

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
// ReggH4-Regesten und Datumsangaben aus Google-Docs importieren
LOAD CSV WITH HEADERS FROM "https://docs.google.com/spreadsheets/d/1GLQIH9LA5btZc-VCRd-8f9BjiylDvwu29FwMwksBbrE/export?format=csv&id=1GLQIH9LA5btZc-VCRd-8f9BjiylDvwu29FwMwksBbrE&gid=2138530170" AS line
CREATE (r:Regesta {regid:line.persistentIdentifier, text:line.summary, archivalHistory:line.archival_history,date:line.date_string,ident:line.identifier,regnum:line.regnum,origPlaceOfIssue:line.locality_string, startDate:line.start_date, endDate:line.end_date})
MERGE (d:Date {startDate:line.start_date, endate:line.end_date})
MERGE (r)-[:DATE]->(d)  
;
~~~

Der `LOAD CSV`-Befehl kann noch um die Angabe `WITH HEADERS FROM` ergänzt werden. Dann werden die Angaben in der ersten Zeile für die Identifizierung der Spalten verwendet.
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
|:--------|------|:-------|
|`LOAD CSV WITH HEADERS FROM` "https://docs.google.com/ ..." AS line|line|Import der CSV-Dateien. Es wird jeweils eine Zeile an die Variable line weitergegeben|
|`CREATE` (r:Regest {regid: line.persistent_identifier, Text:line.summary, Überlieferung: line.archival_history, ident:line.identifier})|line.persistent_identifier, line.summary etc. |Erstellung des Regestenknotens. Für die weiteren Befehlt steht der neu erstellt Regestenknoten unter der Variable r zur Verfügung.|
|`MERGE` (d:Datum {startdate: line.start_date, enddate:line.end_date})|line.start_date und line.end_date|Es wird geprüft, ob ein Datumsknoten mit der Datumsangabe schon existiert, falls nicht, wird er erstellt. In jedem Fall steht anschließend der Datumsknoten unter der Variable d zur Verfügung.|
|`MERGE` (o:Ort {ort:line.name, latitude:toFloat(line.latitude), longitude:toFloat(line.longitude)})|line.name ist der Ortsname, die anderen Angaben sind die Geodaten des Ortes|Es wird geprüft, ob ein Ortsknoten schon existiert, falls nicht, wird er erstellt. In jedem Fall steht anschließend der Ortsknoten unter der Variable o zur Verfügung.|
|`MERGE` (r)-[:HAT_DATUM]->(d)|`(r)` ist der Regestenknoten, `(d)` ist der Datumsknoten|Zwischen Regestenknoten und Datumsknoten wird eine `HAT_DATUM`-Kante erstellt.|
|`MERGE` (r)-[:HAT_ORT]->(o);|`(r)` ist der Regestenknoten, `(o)` ist der Ortsknoten|Zwischen Regestenknoten und Ortsknoten wird eine `HAT_ORT`-Kante erstellt.|

# Erstellen der Ausstellungsorte

In den Kopfzeilen der Regesten ist, soweit bekannt, der Ausstellungsort der Urkunde vermerkt. Im Rahmen der Arbeiten an den Regesta Imperii Online wurden diese Angaben zusammengestellt und soweit möglich die Orte identifiziert, so dass diese Angabe nun bei der Erstellung der Regestendatenbank im Graphen berücksichtigt werden können. Insgesamt befinden sich in den Regesta Imperii über 12.000 verschiedene Angaben für Ausstellungsorte, wobei sie sich teilweise aber auch auf den gleichen Ort beziehen können (Wie z.B. Aachen, Aquisgrani, Aquisgradi, Aquisgranum, coram Aquisgrano etc.). Allein mit den 1.000 häufigsten Ortsangaben konnten schon die Ausstellungsorte der Mehrzahl der Regesten georeferenziert werden.

Mit dem folgenden cypher-Query werden die Ausstellungsorte in die Graphdatenbank importiert:

~~~cypher
// RI-Ausstellungsorte-geo erstellen
LOAD CSV WITH HEADERS FROM "https://docs.google.com/spreadsheets/d/13_f6Vja4HfOpju9RVDubHiMLzS6Uoa7MIOHFEg5V7lw/export?format=csv&id=13_f6Vja4HfOpju9RVDubHiMLzS6Uoa7MIOHFEg5V7lw&gid=420547059" AS line
WITH line
WHERE line.Lat IS NOT NULL
AND line.normalisiertDeutsch IS NOT NULL
MATCH (r:Regesta {origPlaceOfIssue:line.Original})
MERGE (p:Place {normalizedGerman:line.normalisiertDeutsch, longitude:line.Long, latitude:line.Lat})
WITH r, p, line
MERGE (r)-[rel:PLACE_OF_ISSUE]->(p)
SET p.wikidataId = line.wikidataId
SET p.name = line.name
SET p.gettyId = line.GettyId
SET p.geonamesId = line.GeonamesId
SET rel.original = line.Original
SET rel.alternativeName = line.Alternativname
SET rel.commentary = line.Kommentar
SET rel.allocation = line.Zuordnung
SET rel.state = line.Lage
SET rel.certainty = line.Sicherheit
SET rel.institutionInCity = line.InstInDerStadt
RETURN count(p)
;
~~~

Da Import-Query ist etwas komplexer ist, wird er im folgenden näher erläutert. Nach dem `LOAD CSV WITH HEADERS FROM`-Befehl wird zunächst überprüft, ob der jeweils eingelesene Eintrag in der Spalte `line.lat` und in der Spalte `line.normalisiertDeutsch` Einträge hat. Ist dies der Fall wird überprüft, ob es einen Regestenknoten gibt, der einen Ausstellungsorteintrag hat, der der Angabe in der Spalte `Original` entspricht. Diese Auswahl ist notwendig, da in der Tabelle die Ausstellungsorte der gesamten Regesta Imperii enthalten sind, wir beim Import aber nur die Ortsknoten erstellen, die für die Regesten Kaiser Heinrichs IV. relevant sind. Sind die genannten Bedingungen erfüllt, wird mit dem `MERGE`-Befehl der `Place`-Knoten erstellt und anschließend mit dem Regestenknoten verknüpft. Schließlich werden noch weitere Details der Ortsangabe im `Place`-Knoten und in den `PLACE_OF_ISSUE`-Kanten ergänzt.

Mit dem folgenden Query werden die Koordinatenangaben zu Höhen- und Breitengraden der Ausstellungsorte (`Place`-Knoten), die in den Propertys Lat und Long abgespeichert sind in der neuen Property LatLong zusammengefasst und in `point`-Werte umgewandelt. Seit Version 3 kann neo4j mit diesen Werten Abstandsberechnungen durchführen (Mehr dazu siehe unten bei den Auswertungen).

~~~cypher
// Regesten und Ausstellungsorte mit Koordinaten der Ausstellungsorte versehen
MATCH (r:Regesta)-[:PLACE_OF_ISSUE]->(o:Place)
SET r.latLong = point({latitude: tofloat(o.latitude), longitude: tofloat(o.longitude)})
SET o.latLong = point({latitude: tofloat(o.latitude), longitude: tofloat(o.longitude)})
SET r.placeOfIssue = o.normalizedGerman
SET r.latitude = o.latitude
SET r.longitude = o.longitude
;
~~~

In den Regesta Imperii Online sind die Datumsangaben der Regesten iso-konform im Format JJJJ-MM-TT (also Jahr-Monat-Tag) abgespeichert. neo4j behandelt diese Angaben aber als String. Um Datumsberechnungen durchführen zu können, müssen die Strings in Datumswerte umgerechnet werden. Der cypher-Query hierzu sieht wie folgt aus:

~~~cypher
// Date in Isodatum umwandeln
MATCH (n:Regesta)
SET n.isoStartDate = date(n.startDate);
MATCH (n:Regesta)
SET n.isoEndDate = date(n.endDate);
MATCH (d:Date)
SET d.isoStartDate = date(d.startDate);
MATCH (d:Date)
SET d.isoEndDate = date(d.endDate);
~~~

Zunächst werden mit dem `MATCH`-Befehl alle Regestenknoten aufgerufen. Anschließend wird für jeden Regestenknoten aus der String-Property `startDate` die Datumsproperty `isoStartDate` berechnet und im Regestenknoten abgespeichert. Mit Hilfe der Property können dann Datumsangaben und Zeiträume abgefragt werden (Beispiel hierzu unten in der Auswertung).

### Herrscherhandeln in den Regesta Imperii

Regesten sind in ihrer Struktur stark formalisiert. Meist wird mit dem ersten Verb im Regest das Herrscherhandeln beschrieben. Um dies auch digital auswerten zu können haben wir in einem kleinen Testprojekt mit Hilfe des Stuttgart-München Treetaggers aus jedem Regest das erste Verb extrahiert und normalisiert. Die Ergebnisse sind in folgender [Tabelle](https://docs.google.com/spreadsheets/d/1nlbZmQYcT1E3Z58yPmcnulcNQc1e3111Di-4huhV-FY/edit?usp=sharing) einsehbar. Diese Tabelle wird mit dem folgenden cypher-Query in die Graphdatenbank eingelesen.

~~~cypher
// ReggH4-Herrscherhandeln
LOAD CSV WITH HEADERS FROM "https://docs.google.com/spreadsheets/d/1nlbZmQYcT1E3Z58yPmcnulcNQc1e3111Di-4huhV-FY/export?format=csv&id=1nlbZmQYcT1E3Z58yPmcnulcNQc1e3111Di-4huhV-FY&gid=267441060"
AS line FIELDTERMINATOR ','
MATCH (r:Regesta{ident:line.regid})
MERGE (l:Lemma{lemma:line.Lemma})
MERGE (r)-[:ACTION]->(l);
~~~

Dabei wird zunächst mit dem `MATCH`-Befehl das jeweilige Regest gesucht, anschließend mit dem `MERGE`-Befehl der `Lemma`-Knoten für das Herrscherhandeln angelegt (falls noch nicht vorhanden) und schließlich der `Regesta`-knoten mit dem `Lemma`-Knoten übder eine `ACTION`-Kante verbunden. Auswertungsperspektiven finden Sie hier ####

### Zitationsnetzwerke in den Regesta Imperii

In vielen Online-Regesten ist die zitierte Literatur mit dem [Regesta-Imperii-Opac](http://opac.regesta-imperii.de/lang_de/) verlinkt. Da es sich um URLs handelt, sind diese Verweise eindeutig andererseits lassen sie sich mit regulären Ausdrücken aus den Regesten extrahieren. Mit folgendem Query werden aus den Überlieferungsteilen der Regesten die mit dem Opac verlinkten Literaturangaben extrahiert und jede Literaturangabe als `Refernce`-Knoten angelegt.

~~~cypher
// ReggH4-Literaturnetzwerk erstellen
MATCH (reg:Regesta)
WHERE reg.archivalHistory CONTAINS "link"
UNWIND apoc.text.regexGroups(reg.archivalHistory, "<link (\\S+)>(\\S+)</link>") as link
MERGE (ref:Reference {url:link[1]}) ON CREATE SET ref.title=link[2]
MERGE (reg)-[:REFERENCES]->(ref);
~~~

Da dies mit dem `MERGE`-Befehl geschieht, wird in der Graphdatenbank jeder Literaturtitel nur einmal angelegt. Anschließend werden die `Reference`-Knoten mit den Regesten über `REFERNCES`-Kanten verbunden. Zu den Auswertungsmöglichkeiten vgl. unten den Abschnitt zu den [Auswertungsperspektiven](#Auswertungsperspektiven).


# Import der Registerdaten in die Graphdatenbank

## Vorbereitung der Registerdaten

Register spielen für die Erschließung von gedrucktem Wissen eine zentrale Rolle, da dort in alphabetischer Ordnung die im Werk vorkommenden Entitäten (z.B. Personen und Orte) hierarchisch gegliedert aufgeschlüsselt werden. Für die digitale Erschließung der Regesta Imperii sind Register von zentraler Bedeutung, da mit ihnen die in den Regesten vorkommenden Personen und Orte bereits identifiziert vorliegen. Für den Import in die Graphdatenbank wird allerdings eine digitalisierterte Fassung des Registers benötigt. Im Digitalisierungsprojekt Regesta Imperii Online wurden Anfang der 2000er Jahre auch die gedruckt vorliegenden Register digitalisiert. Sie dienen nun als Grundlage für die digitale Registererschließung der Regesta Imperii. Im hier gezeigten Beispiel werden die Regesten Kaiser Heinrichs IV. und das dazugehörige Register importiert. Da der letzte Regestenband der Regesten Kaiser Heinrichs IV. mit dem Gesamtregister erst vor kurzem gedruckt wurde, liegen hier aktuelle digitale Fassung von Registern und Regesten vor. Die für den Druck in Word erstellte Registerfassung wird hierfür zunächst in eine hierarchisch gegliederte XML-Fassung konvertiert, damit die Registerhierarchie auch maschinenlesbar abgelegt ist.

![Ausschnitt aus dem XML-Register der Regesten Heinrichs IV.](/Graphentechnologien/Bilder/RI2Graph/XML-Register.png)

In der XML-Fassung sind die inhaltlichen Bereiche und die Abschnitte für die Regestennummern jeweils extra in die Tags `<Inhalt` und `Regestennummer` eingefasst. Innerhalb des Elements `Regestennummer` ist dann nochmal jede einzelne Regestennummer in `<r>`-Tags eingefasst. Die aus dem gedruckten Register übernommenen Verweise sind durch ein leeres `<vw/>`-Element gekennzeichnet.

Die in XML vorliegenden Registerdaten werden anschließend mit Hilfe von TuStep in einzelne CSV-Tabellen zerlegt.

![Ausschnitt der Entitätentabelle des Registers der Regesten Heinrichs IV.](/Graphentechnologien/Bilder/RI2Graph/RegisterH4-Tabelle-Entitäten.png)

In einer Tabelle werden alle Entitäten aufgelistet und jeweils mit einer ID versehen.

![Ausschnitt der Verknüpfungstabelle des Registers der Regesten Heinrichs IV.](/Graphentechnologien/Bilder/RI2Graph/RegisterH4-GENANNT.png)

In der anderen Tabelle werden die Verknüpfungen zwischen Registereinträgen und den Regesten aufgelistet. Der Registereintrag Adalbero kommt also in mehreren Regesten vor. Da das Register der Regesten Heinrichs IV. nur zwei Hierarchiestufen enthält, in denen beispielsweise verschiedene Amtsphasen ein und derselben Person unterschieden werden, wurden diese beim Import zusammengefasst.[^5979] Damit gibt es pro Person jeweils nur einen Knoten.

## Import der Registerdaten in die Graphdatenbank

Im Gegensatz zu den Regesten Kaiser Friedrichs III., bei denen Orte und Personen in einem Register zusammengefasst sind, haben die Regesten Kaiser Heinrich IV. getrennte Orts- und Personenregister. Die digitalisierten Registerdaten können [hier](https://docs.google.com/spreadsheets/d/12T-RD1Ct4aAUNNNxipjMmHe9F1NmryI1gf8_SJ4RCEE/edit?usp=sharing) eingesehen werden. In dem Tabellendokument befinden sich insgesamt drei Tabellen. In der Tabelle Personen sind die Einträge des Personenregisters aufgelistet und in der Tabelle Orte befindet sich die Liste aller Einträge des Ortsregisters. Schließlich enthält die Tabelle `APPEARS_IN` Information dazu, welche Personen oder Orte in welchen Regesten genannt sind. Der folgende cypher-Query importiert die Einträge der Personentabelle in die Graphdatenbank und erstellt für jeden Eintrag einen Knoten vom Typ `:IndexPerson`:

~~~cypher
// Registereinträge Personen erstellen
LOAD CSV WITH HEADERS FROM "https://docs.google.com/spreadsheets/d/12T-RD1Ct4aAUNNNxipjMmHe9F1NmryI1gf8_SJ4RCEE/export?format=csv&id=12T-RD1Ct4aAUNNNxipjMmHe9F1NmryI1gf8_SJ4RCEE&gid=1167029283"
AS line
CREATE (:IndexPerson {registerId:line.ID, name1:line.name1});
~~~

Mit dem folgenden cypher-Query werden nach dem gleichen Muster aus der Tabelle `Orte` die Ortseinträge in die Graphdatenbank importiert.

~~~cypher
OAD CSV WITH HEADERS FROM "https://docs.google.com/spreadsheets/d/12T-RD1Ct4aAUNNNxipjMmHe9F1NmryI1gf8_SJ4RCEE/export?format=csv&id=12T-RD1Ct4aAUNNNxipjMmHe9F1NmryI1gf8_SJ4RCEE&gid=2049106817"
AS line
CREATE (:IndexPlace {registerId:line.ID, name1:line.name1});
~~~

Die beiden Befehle greifen also auf verschiedene Tabellenblätter des gleichen Google-Tabellendokuments zu, laden es als CSV-Daten und übergeben die Daten zeilenweise an die weiteren Befehle (Hier an den `MATCH`- und den `CREATE`-Befehl).
Im nächsten Schritt werden nun mit den Daten der `APPEARS_IN`-Tabelle die Verknüpfungen zwischen den Registereinträgen und den Regesten erstellt.

~~~cypher
// PLACE_IN-Kanten für Orte erstellen
LOAD CSV WITH HEADERS FROM "https://docs.google.com/spreadsheets/d/12T-RD1Ct4aAUNNNxipjMmHe9F1NmryI1gf8_SJ4RCEE/export?format=csv&id=12T-RD1Ct4aAUNNNxipjMmHe9F1NmryI1gf8_SJ4RCEE&gid=2147130316"
AS line
MATCH (from:IndexPlace {registerId:line.ID})
MATCH (to:Regesta {regnum:line.regnum2})
CREATE (from)-[:PLACE_IN {regnum:line.regnum, name1:line.name1, name2:line.name2}]->(to);
~~~

Dabei werden zunächst mit den beiden `MATCH`-Befehlen jeweils das Regest und der Registereintrag aufgerufen und schließend mit dem `CREATE`-Befehl eine `PLACE_IN`-Kante zwischen den beiden Knoten angelegt, die als Attribute den Inhalt der Spalten `name1` und `name2` mitbekommt.
Analog werden die Verknüpfungen zwischen Regestenknoten und Personenknoten angelegt:

~~~cypher
// PERSON_IN-Kanten für Person erstellen
LOAD CSV WITH HEADERS FROM "https://docs.google.com/spreadsheets/d/12T-RD1Ct4aAUNNNxipjMmHe9F1NmryI1gf8_SJ4RCEE/export?format=csv&id=12T-RD1Ct4aAUNNNxipjMmHe9F1NmryI1gf8_SJ4RCEE&gid=2147130316"
AS line
MATCH (from:IndexPerson {registerId:line.ID}), (to:Regesta {regnum:line.regnum2})
CREATE (from)-[:PERSON_IN {regnum:line.regnum, name1:line.name1, name2:line.name2}]->(to);
~~~

## Die Hierarchie des Registers der Regesten Kaiser Friedrichs III.
In anderen Registern der Regesta Imperii, wie beispielsweise den Regesten Kaiser Friedrichs III. sind teilweise fünf oder mehr Hierarchiestufen vorhanden, die jeweils auch Entitäten repräsentieren. In diesen Fällen müssen die Hierarchien auch in der Graphdatenbank abgebildet werden, was durch zusätzliche Verweise auf die ggf. vorhandenen übergeordneten Registereinträge möglich wird.

![Ausschnitt der Entitätentabelle des Registers der Regesten Friedrichs III.](/Graphentechnologien/Bilder/RI2Graph/RegisterF3-Hierarchie.png)

Im Tabellenausschnitt wird jedem Registereintrag in der ersten Spalte eine `nodeID` als eindeutige Kennung zugewiesen. Bei Registereinträgen, die kein Hauptlemma sind, enthält die dritte Spalte `topnodeID` den Verweis auf die eindeutige Kennung `nodeID` des übergeordneten Eintrages. Beim Import in die Graphdatenbank wird diese Hierarchie über `CHILD_OF`-Kanten abgebildet, die vom untergeordneten Eintrag auf das übergeordnete Lemma verweisen. Damit ist die komplette Registerhierarchie im Graphen abgebildet. In der Spalte `name1` ist das Lemma angegeben, in der Spalte `name3` zusätzliche zum Lemma noch der gesamte Pfad vom Hauptlemma bis zum Registereintrag, jeweils mit Doppelslahes (`//`) getrennt. Bei tiefer gestaffelten Registern ist teilweise ohne Kenntnis der übergeordneten Einträge eine eindeutige Identifizierung eines Eintrages nicht möglich. So wird in Zeile 17 der o.a. Abbildung allein mit der Angabe aus der Spalte `name1` nicht klar ist, um welche `Meierei` es sich handelt. Mit dem kompletten Pfad des Registereintrages in der Spalte `name3` wird dagegen deutlich, dass die Aachener `Meierei` gemeint ist.

# Auswertungsperspektiven

## Personennetzwerke in den Registern

### Graf Robert II. von Flandern in seinem Netzwerk

Nach dem Import können nun die Online-Regesten und die Informationen aus dem Registern der Regesten Kaiser Heinrichs IV. in einer Graphdatenbank aus einer Vernetzungsperspektive abgefragt werden.[^f663]

Ausgangspunkt ist der Registereintrag von Graf Robert II. von Flandern. Diesen Knoten finden wir mit folgendem Query.

~~~cypher
// Robert II. von Flandern
MATCH (n:IndexPerson) WHERE n.registerId = 'H4P01822'
RETURN *;
~~~

Mit einem Doppelklick auf den `IndexPerson`-Knoten öffnen sich alle `Regesta`-Knoten, in denen Robert genannt ist. Klickt man nun wiederum alle Regestenknoten doppelt, sieht man alle Personen und Orte, mit denen Robert gemeinsam in den Regesten genannt ist.

Dies kann auch in einem cypher-Query zusammengefasst werden.

~~~cypher
// Robert II. von Flandern mit Netzwerk
MATCH (n:IndexPerson)-[:PERSON_IN]->
(r:Regesta)<-[:PERSON_IN]-
(m:IndexPerson)
WHERE n.registerId = 'H4P01822'
RETURN *;
~~~

In der folgenden Abb. wird das Ergebnis dargestellt.

![Robert mit den Personen, mit denen er gemeinsam in Regesten genannt wird.](/Graphentechnologien/Bilder/RI2Graph/RobertVonFlandernMitRegesten.png)

Hier wird der `MATCH`-Befehl um einen Pfad über `PERSON_IN`-Kanten zu `Regesta`-Knoten ergänzt, von denen dann wiederum eine `PERSON_IN`-Kante zu den anderen, in den Regesten genannten `IndexPerson`-Knoten führt.

Nimmt man noch eine weitere Ebene hinzu, wächst die Ergebnismenge start an.

~~~cypher
// Robert II. von Flandern mit Netzwerk und Herrscherhandeln (viel)
MATCH
(n1:IndexPerson)-[:PERSON_IN]->(r1:Regesta)<-[:PERSON_IN]-
(n2:IndexPerson)-[:PERSON_IN]->(r2:Regesta)<-[:PERSON_IN]-
(n3:IndexPerson)
WHERE n1.registerId = 'H4P01822'
RETURN *;
~~~

![Robert mit Personen, die wiederum mit Personen gemeinsam in Regesten genannt sind.](/Graphentechnologien/Bilder/RI2Graph/Robert-viel.png)



~~~cypher
// Robert II. von Flandern und Herzog Heinrich von Niederlothringen mit Netzwerk
MATCH
(n:IndexPerson)-[:PERSON_IN]->
(r:Regesta)<-[:PERSON_IN]-(m:IndexPerson)
WHERE n.registerId = 'H4P01822'
AND m.registerId = 'H4P00926'
RETURN *;
~~~

~~~cypher
// Rausrechnen der dazwischenliegenden Knoten
MATCH
(startPerson:IndexPerson)-[:PERSON_IN]->
(regest:Regesta)<-[:PERSON_IN]-(endPerson:IndexPerson)
WHERE startPerson.registerId in ['H4P01822', 'H4P00926']
WITH startPerson, endPerson, count(regest) as anzahl,
collect(regest.ident) as idents
CALL apoc.create.vRelationship(startPerson, "KNOWS",
{anzahl:anzahl, regesten:idents}, endPerson) YIELD rel
RETURN startPerson, endPerson, rel
~~~

~~~cypher
// Liste der Regesten als Ergebnis
MATCH
(startPerson:IndexPerson)-[:PERSON_IN]->
(regest1:Regesta)<-[:PERSON_IN]-(middlePerson:IndexPerson)
-[:PERSON_IN]->(regest2:Regesta)
<-[:PERSON_IN]-(endPerson:IndexPerson)
WHERE startPerson.registerId in ['H4P00926']
AND endPerson.registerId in ['H4P01822']
RETURN DISTINCT startPerson.name1, regest1.ident, regest1.text,
middlePerson.name1, regest2.ident, regest2.text, endPerson.name1;
~~~

## Herrscherhandeln ausgezählt

~~~cypher
// Herrscherhandeln ausgezählt
MATCH (n:Lemma)<-[h:ACTION]-(m:Regesta)
RETURN n.lemma, count(h) as ANZAHL ORDER BY ANZAHL desc LIMIT 25;
~~~

## Herrscherhandeln pro Ausstellungsort ausgezählt

~~~cypher
// Herrscherhandeln pro Ausstellungsort
MATCH (n:Lemma)<-[h:ACTION]-(:Regesta)-[:PLACE_OF_ISSUE]->(p:Place)
WHERE p.name <> '–' AND
p.name <> '‒'
RETURN p.name, n.lemma, count(h) as ANZAHL ORDER BY ANZAHL desc LIMIT 25;
~~~

## Welche Literatur wird am meisten zitiert

~~~cypher
MATCH (n:Reference)<-[r:REFERENCES]-(m:Regesta)
RETURN n.title, count(r) as ANZAHL ORDER BY ANZAHL desc LIMIT 25;
~~~

## Herrscherhandeln und Anwesenheit

~~~cypher
MATCH (p:IndexPerson)-[:PERSON_IN]-(r:Regesta)-[:ACTION]-(l:Lemma)
RETURN p.name1, l.lemma, count(l) AS Anzahl ORDER BY p.name1, Anzahl DESC;
~~~

## Regesten 200 km rund um Augsburg

~~~cypher
// Entfernungen von Orten berechnen lassen
MATCH (n:Place)
WHERE n.normalizedGerman = 'Augsburg'
WITH n.latLong as point
MATCH (r:Regesta)
WHERE distance(r.latLong, point) < 200000
AND r.placeOfIssue IS NOT NULL
AND r.placeOfIssue <> 'Augsburg'
RETURN r.ident, r.placeOfIssue,
distance(r.latLong, point) AS Entfernung
ORDER BY Entfernung;
~~~



[^5147]: Verwendet wird die Graphdatenbank neo4j. Die Community-Edition ist kostenlos erhältlich unter [https://www.neo4j.com](https://www.neo4j.com).
[^892b]: Dies ist das Tabellenkalkulationsformat von Libreoffice und Openoffice. Vgl.  [https://de.libreoffice.org](https://de.libreoffice.org).

[^336e]: Die Angaben in der Graphdatenbank sind Englisch, daher *Regesta*.

[^d219]: Gemeint ist hier der lowerCamelCase bei dem der erste Buchstabe kleingeschrieben und dann jedes angesetzte Wort mit einem Großbuchstaben direkt angehängt (wie bei archivalHistory). Vgl. auch https://de.wikipedia.org/wiki/Binnenmajuskel#Programmiersprachen.

[^5979]: Vgl. die Vorbemerkung zum Register in Böhmer, J. F., Regesta Imperii III. Salisches Haus 1024-1125. Tl. 2: 1056-1125. 3. Abt.: Die Regesten des Kaiserreichs unter Heinrich IV. 1056 (1050) - 1106. 5. Lief.: Die Regesten Rudolfs von Rheinfelden, Hermanns von Salm und Konrads (III.). Verzeichnisse, Register, Addenda und Corrigenda, bearbeitet von Lubich, Gerhard unter Mitwirkung von Junker, Cathrin; Klocke, Lisa und Keller, Markus - Köln (u.a.) (2018), S. 291.

[^595c]: Vgl. Kuczera, Andreas; Schrade, Torsten: From Charter Data to Charter Presentation: Thinking about Web Usability in the Regesta Imperii Online. Vortrag auf der Tagung ›Digital Diplomatikcs 2013 – What ist Diplomatics in the Digital Environment?‹ Folien: https://prezi.com/vvacmdndthqg/from-charta-data-to-charta-presentation/.
[^0b8f]: Näheres dazu in Kuczera, Andreas: Digitale Perspektiven mediävistischer Quellenrecherche, in: Mittelalter. Interdisziplinäre Forschung und Rezeptionsgeschichte, 18.04.2014. URL: mittelalter.hypotheses.org/3492.

[^3273]: Vgl. beispielsweise Gramsch, Robert: Das Reich als Netzwerk der Fürsten - Politische Strukturen unter dem Doppelkönigtum Friedrichs II. und Heinrichs (VII.) 1225-1235. Ostfildern, 2013. Einen guten Überblick bietet das
Handbuch Historische Netzwerkforschung - Grundlagen und Anwendungen. Herausgegeben von
Marten Düring, Ulrich Eumann, Martin Stark und Linda von Keyserlingk. Berlin 2016.

[^ce4b]: Regesta chronologico-diplomatica Friderici III. Romanorum imperatoris (regis IV.) : Auszug aus den im K.K. Geheimen Haus-, Hof- und Staats-Archive zu Wien sich befindenden Registraturbüchern vom Jahre 1440 - 1493 ; nebst Auszügen aus Original-Urkunden, Manuscripten und Büchern / von Joseph Chmel, Wien 1838 und 1840.

[^6155]: Der cypher-Befehl zur Erstellung der 1zu1-Beziehungen lautet: *MATCH (n1:Registereintrag)-[:APPEARS_IN]->(r:Regest)<-[:APPEARS_IN]-(n2:Registereintrag)
MERGE (n1)-[:KNOWS]->(n2);* Dabei werden die gerichteten `KNOWS`-Kanten jeweils in beide Richtungen erstellt.
Mit folgendem Befehl lassen sich die `KNOWS`-Kanten zählen: *MATCH p=()-[r:KNOWS]->() RETURN count(p);* Für die Bestimmung der 1zu1-Beziehungen muss der Wert noch durch 2 geteilt werden.

[^7a43]: Letztgenannte Tabelle existiert nur aus historischen Gründen und wird beim Import nicht mehr berücksichtigt.

[^f663]: Die nun folgenden Abfragen sind zum Teil einer Präsentation entnommen, die für die Summerschool der [Digitalen Akademie](https://www.digitale-akademie.de) im Rahmen des [Mainzed](https://www.mainzed.org/de) entwickelt wurden. Die Präsentation findet sich unter der URL [https://digitale-methodik.adwmainz.net/mod5/5c/slides/graphentechnologien/RI.html](https://digitale-methodik.adwmainz.net/mod5/5c/slides/graphentechnologien/RI.html).