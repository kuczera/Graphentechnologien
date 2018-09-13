
# Historische Netzwerkanalyse

## Die Register der Regesta Imperii


## Explorative Datenanalyse oder was ist in der Datenbank darin

Zeigt alle Knoten und ihre Häufigkeiten

~~~cypher
CALL db.labels()
YIELD label
CALL apoc.cypher.run("MATCH (:`"+label+"`)
RETURN count(*) as count", null)
YIELD value
RETURN label, value.count as count
ORDER BY label
~~~

Zeigt alle Verknüpfungen und ihre Häufigkeiten in der Datenbank

~~~cyper
CALL db.relationshipTypes()
YIELD relationshipType
CALL apoc.cypher.run("MATCH ()-[:" + 'relationshipType' + "]->()
RETURN count(*) as count", null)
YIELD value
RETURN relationshipType, value.count AS count
ORDER BY relationshipType
~~~

## Zentralitätsalgorithmen in der historischen Netzwerkanalyse

### PageRank

Was macht der PageRank-Algorithmus ?

~~~cyper
CALL algo.pageRank.stream("IndexPerson", "KNOWS",
{iterations:20})
YIELD nodeId, score
MATCH (node) WHERE id(node) = nodeId
RETURN node.shortName AS Person,
apoc.math.round(score,3)
ORDER BY score DESC
~~~

### Degree Centrality

~~~cyper
MATCH (u:IndexPerson)
RETURN u.name1 AS name,
size((u)-[:KNOWS]->()) AS follows,
size((u)<-[:KNOWS]-()) AS followers
ORDER by followers DESC
~~~

### Betweenes Centrality

~~~cyper
// betweenness centrality
CALL algo.betweenness.stream("IndexPerson",
"KNOWS", {direction: "OUTGOING", iterations: 10}) YIELD nodeId, centrality
MATCH (p:IndexPerson) WHERE id(p) = nodeId
RETURN p.name1 AS Name, centrality
ORDER by centrality DESC;
~~~

### Closeness Centrality

~~~cyper
// betweenness centrality
CALL algo.closeness.stream("IndexPerson", "KNOWS")
YIELD nodeId, centrality
MATCH (n:IndexPerson) WHERE id(n) = nodeId
RETURN n.name1 AS node, apoc.math.round(centrality,2)
ORDER BY centrality DESC
LIMIT 30;
~~~

## Community Detection Algorithmen

### Strongly Connected Components

~~~cyper
CALL algo.scc.stream("IndexPerson","KNOWS")
YIELD nodeId, partition
MATCH (u:IndexPerson) WHERE id(u) = nodeId
RETURN u.name1 AS name, partition
ORDER BY partition DESC;
~~~

### Weakly Connected Components

~~~cyper
CALL algo.unionFind.stream("IndexPerson","KNOWS")
YIELD nodeId, setId
MATCH (u:IndexPerson) WHERE id(u) = nodeId
RETURN u.name1 AS name, setId;
~~~

### Label Propagation

~~~cypher
CALL algo.labelPropagation.stream("IndexPerson",
"KNOWS", {direction: "OUTGOING", iterations: 10})
YIELD nodeId, label
MATCH (p:IndexPerson) WHERE id(p) = nodeId
RETURN p.name1 AS Name, label ORDER BY label DESC;
~~~

### Louvain Modularity

~~~cyper
CALL algo.louvain.stream("IndexPerson",
"KNOWS", {})
YIELD nodeId, community
MATCH (user:IndexPerson) WHERE id(user) = nodeId
RETURN user.name1 AS user, community
ORDER BY community;
~~~

### Triangle count and Clustering Coefficient

~~~cyper
CALL algo.triangle.stream("IndexPerson","KNOWS")
YIELD nodeA,nodeB,nodeC
MATCH (a:IndexPerson) WHERE id(a) = nodeA
MATCH (b:IndexPerson) WHERE id(b) = nodeB
MATCH (c:IndexPerson) WHERE id(c) = nodeC
RETURN a.shortName AS nodeA, b.shortName AS nodeB, c.shortName AS node

~~~

direkt aus dem Beispiel übernommen

~~~cyper
CALL algo.triangleCount.stream('IndexPerson', 'KNOWS')
YIELD nodeId, triangles, coefficient
MATCH (p:IndexPerson) WHERE id(p) = nodeId
RETURN p.name1 AS name, triangles, coefficient
ORDER BY coefficient DESC
~~~

nach der Anzahl der Dreiecksbeziehungen sortiert

~~~cyper
CALL algo.triangleCount.stream('IndexPerson', 'KNOWS')
YIELD nodeId, triangles, coefficient
MATCH (p:IndexPerson) WHERE id(p) = nodeId
RETURN p.name1 AS name, triangles, coefficient
ORDER BY triangles DESC
~~~


~~~cypher

~~~


~~~cypher
CALL algo.labelPropagation.stream("IndexPerson", "KNOWS", {direction: "OUTGOING", iterations: 10}) YIELD nodeId, label
MATCH (p:IndexPerson) WHERE id(p) = nodeId
RETURN p.name1 AS Name, label ORDER BY label DESC;
~~~

~~~cypher
CALL algo.triangle.stream("IndexPerson","KNOWS")
YIELD nodeA,nodeB,nodeC
MATCH (a:IndexPerson) WHERE id(a) = nodeA
MATCH (b:IndexPerson) WHERE id(b) = nodeB
MATCH (c:IndexPerson) WHERE id(c) = nodeC
RETURN a.shortName AS nodeA, b.shortName AS nodeB, c.shortName AS node
~~~
