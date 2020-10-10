
import sequtils
import strutils
import sets
import hashes
import sugar
import math
import algorithm
import tables

type Coord = object
    x, y: int

proc hash(c: Coord): Hash =
    var h: Hash = 0
    h = h !& c.x
    h = h !& c.y
    result = !$h

proc `+`(this, other: Coord): Coord =
    Coord(x: this.x + other.x, y: this.y + other.y)

proc vecsForWire(wire: seq[string]): seq[Coord] =
    for segment in wire:
        let dir = segment[0]
        let x = (if dir == 'R': 1 elif dir == 'L': -1 else: 0)
        let y = (if dir == 'U': 1 elif dir == 'D': -1 else: 0)
        let go = Coord(x: x, y: y)
        let times = segment[1..^1].parseInt
        for _ in 0..<times:
            result.add(go)



proc coordsForWire(vecs: seq[Coord]): seq[Coord] =
    result = @[Coord(x: 0, y: 0)]
    for v in vecs:
        # echo "adding ", result[^1], "and", v
        result.add(result[^1] + v)



if isMainModule:
    var wires: seq[seq[string]]
    for line in lines("inputs/day3.txt"):
        let dirs = line.strip().split(",")
        wires.add(dirs)

    let wireVecs = wires.map(vecsForWire)
    # echo "\n\nwirevecs: ", wireVecs
    let wireCoords = wireVecs.map(coordsForWire)
    # echo "\n\nwirecoords: ", wireCoords

    let wireHashes = wireCoords.mapIt(it.toHashSet)
    # echo repr wireHashes

    let intersections = intersection(wireHashes[0], wireHashes[1])

    var distances = intersections.mapIt(it.x.abs + it.y.abs)
    distances.sort(Ascending)
    echo "day 3 part 1: ", distances[0..1]

    var intsWireLengths = collect(newSeq):
        for inters in intersections:
            wireCoords.mapIt(it.find(inters)).sum()

    intsWireLengths.sort(Ascending)
    echo "day 3 part 2: ", intsWireLengths[0..1]