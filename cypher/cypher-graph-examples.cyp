//ABC directTransitive
MATCH (n) DETACH DELETE n;
CREATE (A:Person {name:'Person A'})-[:DIRECT_RELATION]->(B:Person {name:'Person B'})-[:DIRECT_RELATION]->(C:Person {name:'Person C'})<-[:TRANSITIVE_RELATION]-(A);

//SimpleGraph
MATCH (n) DETACH DELETE n;
CREATE (A:Person {name:'Node A'})-[:RELATION]->(B:Person {name:'Node B'})-[:RELATION]->(C:Person {name:'Node C'})-[:RELATION]->(D:Person {name:'Node D'})-[:RELATION]->(A);

// MultiGraph
MATCH (n) DETACH DELETE n;
CREATE (A:Person {name:'Node A'})-[:RELATION]->(B:Person {name:'Node B'})-[:RELATION]->(C:Person {name:'Node C'})-[:RELATION]->(D:Person {name:'Node D'})-[:RELATION]->(A);


// Weighted
MATCH (n) DETACH DELETE n;
CREATE (D:Person {name:'Node D'})-[:RELATION {weight:'RELATION: 30'}]->(B:Person {name:'Node B'})-[:RELATION {weight:'RELATION: 50'}]->(C:Person {name:'Node C'})-[:RELATION {weight:'RELATION: 10'}]->(A:Person {name:'Node A'})-[:RELATION {weight:'RELATION: 70'}]->(E:Person {name:'Node E'})
CREATE (D)-[:RELATION {weight:'RELATION: 90'}]->(C)
;

// Unweighted
