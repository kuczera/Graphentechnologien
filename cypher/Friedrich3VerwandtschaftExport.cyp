// Exportiert Kaiser Friedrich III. mit zwei Verwandtschaftssprüngen
CALL apoc.export.cypher.query(
'MATCH (n:wikidataPerson {wikidataId:"Q150966"})-[r1]-(n1)-[r2]-(n2) RETURN *',
'/tmp/export.cypher',{format:'cypher-shell'});

