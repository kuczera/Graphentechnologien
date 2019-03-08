---
title: JSON Import mit den Personendaten der Germania Sacra
layout: default
order: 70
contents: true
---


# Import von JSON in neo4j mit `apoc.load.json`

(Dieser Abschnitt befindet sich in Bearbeitung)

## Das Projekt Germania Sacra

Das Projekt Germania Sacra erschließt die Quellen der Kirche des alten Reiches.[^eeaa] Dabei werden die Kirche und ihre Institutionen von den Anfängen im 3./4. Jahrhundert bis zu deren Auflösung am Beginn des 19. Jahrhunderts dar. Im Rahmen des Projekts werden die überlieferten Quellen nach einheitlichen Kriterien aufgearbeitet und so strukturierte Daten für Kirchengeschichte im alten Reich bereitgestellt. So bildet das Projekt die Grundlage für weiterführende Forschungen.

Neben den Bänden bietet das Projekt auch ein [digitales Personenregister](https://adw-goe.de/forschung/forschungsprojekte-akademienprogramm/germania-sacra/digitales-personenregister/) mit Angaben u.a. zu Personen, Bischöfen, Klöstern und Stiften. Die Daten werden über die [Schnittstellen des Projekts](https://adw-goe.de/forschung/forschungsprojekte-akademienprogramm/germania-sacra/schnittstellen-und-linked-data/) als JSON-Daten bereitgestellt.

## Germania Sacra JSON

### Personen

Die Daten des Projekts umfassen z.B. Angaben zu Namen, Namensalternativen, Daten zu den Personen und der institutionelle Anbindung. Der folgende Ausschnitt aus einer JSON-Datei umfasst beispielhaft zwei Personeneinträge.

```json
{
	"persons": [{
		"person_vorname": "Ludold",
		"person_name": "Ludold von Escherde",
		"person_namensalternativen": "von Goltern (?)",
		"person_gso": "060-02673-001",
		"person_gnd": "",
		"person_bezeichnung": "Abt",
		"person_bezeichnung_plural": "\u00c4bte",
		"person_anmerkung": "",
		"person_von_verbal": "1234",
		"person_von": 1234,
		"person_bis_verbal": "1263",
		"person_bis": 1263,
		"person_office_id": "282620"
	}, {
		"person_vorname": "Hermann",
		"person_name": "Hermann",
		"person_namensalternativen": "",
		"person_gso": "033-02024-001",
		"person_gnd": "",
		"person_bezeichnung": "Abt",
		"person_bezeichnung_plural": "\u00c4bte",
		"person_anmerkung": "",
		"person_von_verbal": "1262",
		"person_von": 1262,
		"person_bis_verbal": "1265",
		"person_bis": 1265,
		"person_office_id": "311579"
	}
```

Die folgende Abbildung zeigt die ersten drei Einträge der JSON-Datei mit den Angaben zu den Klöstern.  

```json

{"kloster":
[
 {
   "bezeichnung": "Adeliges Damenstift Neuburg",
   "ort": "Heidelberg",
   "bistum": "Worms",
   "klosterid": 20595,
   "Wikipedia": "#http://de.wikipedia.org/wiki/Abtei_Neuburg#",
   "GND": "#http://d-nb.info/gnd/4316849-8#",
   "GeonameID_Ortsname": 2907911,
   "Datum_von": 1671,
   "Datum_bis": 1681
 },
 {
   "bezeichnung": "Adeliges weltliches Chorfrauenstift St. Fridolin, Säckingen",
   "ort": "Bad Säckingen",
   "bistum": "Konstanz",
   "klosterid": 20381,
   "Wikipedia": "#http://de.wikipedia.org/wiki/Damenstift_S%C3%A4ckingen#",
   "GND": "#http://d-nb.info/gnd/4343770-9#",
   "GeonameID_Ortsname": 2953363,
   "Datum_von": 501,
   "Datum_bis": 1806
 },
 {
   "bezeichnung": "Adliges Damenstift Frauenalb, zuvor Benediktinerinnenkloster",
   "ort": "Marxzell",
   "bistum": "Speyer",
   "klosterid": 20195,
   "Wikipedia": "",
   "GND": "#http://d-nb.info/gnd/4446800-3#",
   "GeonameID_Ortsname": null,
   "Datum_von": 1180,
   "Datum_bis": 1803
 },

```


[^eeaa]: Zu diesem Abschnitt vgl. [http://www.germania-sacra.de/](http://www.germania-sacra.de/) (zuletzt abgerufen am 07.03.2019).
