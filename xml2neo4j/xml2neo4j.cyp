
call apoc.load.xmlSimple("https://docs.google.com/document/u/0/export?format=txt&id=1Ujx9cdequEvuXx6DxK7xfxbuS63Aq9n_xpLOAcjU_xc&token=AC4w5Vj0yTkdPLob1lo1ajkaG75fynNZ0Q%3A1490694667158") yield value
unwind value._work as wdata
merge (w1:Werk{eid:wdata.id}) set w1.name=wdata._title._text
foreach (name in wdata._autor | merge (p1:Person {Name:name._text}) merge (p1)-[:AUTHOR_OF]->(w1) )
foreach (name in wdata._kommentator | merge (p1:Person {Name:name._text}) merge (p1)-[:COMMENTATOR_OF]->(w1))
foreach (druckort in [x in wdata._druckort._text where x is not null] | merge (o1:Ort{name:druckort}) merge (w1)-[:PRINTED_IN]->(o1));



