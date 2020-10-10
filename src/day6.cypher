// docker run -d --name neo4j -p 7474:7474 -p 7687:7687 neo4j:3.5.3

:param input => "F96)LVN
...
XVV)PZG"

// create scenario
unwind split($input, "\n") as orbit
with split(orbit, ")") as o
merge (l:Body {id: o[0]})
merge (r:Body {id: o[1]})
merge (l)<-[:ORBITS]-(r)

// part 1
match (:Body {id: "COM"})<-[o:ORBITS*]-(:Body)
with size(o) as orbits
return sum(orbits) as part1

// part 2
match (:Body {id: "YOU"})-[:ORBITS]->(s:Body),
      (:Body {id: "SAN"})-[:ORBITS]->(e:Body),
      p = shortestPath((s)-[:ORBITS*]-(e))
return length(p) as part2

// clean
match (n:Body) detach delete n


