import httpclient
import json
import base64

const createScenario = """
unwind split($input, "\n") as orbit
with split(orbit, ")") as o
merge (l:Body {id: o[0]})
merge (r:Body {id: o[1]})
merge (l)<-[:ORBITS]-(r)
"""

const part1cypher = """
match (:Body {id: "COM"})<-[o:ORBITS*]-(:Body)
with size(o) as orbits
return sum(orbits) as part1
"""

const part2cypher = """
match (:Body {id: "YOU"})-[:ORBITS]->(s:Body),
      (:Body {id: "SAN"})-[:ORBITS]->(e:Body),
      p = shortestPath((s)-[:ORBITS*]-(e))
return length(p) as part2
"""

const cleanCypher = "match (n:Body) detach delete n"

const neo4jurl = "http://localhost:7474/db/data/transaction/commit"

if isMainModule:
    # start docker:
    # docker run -d --name neo4j -p 7474:7474 -p 7687:7687 neo4j:3.5.3
    var client = newHttpClient()
    client.headers = newHttpHeaders({ "Authorization": "Basic " & encode("neo4j:password")} )

    let payload = %*{
        "statements" : [
            {
                "statement" : createScenario,
                "parameters": {
                    "input": readFile("inputs/day6.txt")
                }
            },
            {
                "statement" : part1cypher
            },
            {
                "statement" : part2cypher
            },
            {
                "statement" : cleanCypher
            },
        ]
    }


    let response = client.post(neo4jurl, body = $payload)
    echo response.body.parseJson.pretty
