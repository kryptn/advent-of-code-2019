import hashes


type Coord* = object
    x*: int
    y*: int

proc hash*(c: Coord): Hash =
    var h: Hash = 0
    h = h !& (c.x + 10*10000)
    h = h !& c.y
    result = !$h

proc `+`*(c:Coord, o:Coord): Coord =
    Coord(x: c.x + o.x, y: c.y + o.y)

proc `-`*(c: Coord, o: Coord): Coord =
    Coord(x: c.x - o.x, y: c.y - o.y)

proc squareAround*(c: Coord, dist: int): seq[Coord] =
    var pos = c + Coord(x: -dist, y: -dist)

    const path = @[Coord(x: 1, y: 0), Coord(x: 0, y: 1), Coord(x: -1, y: 0), Coord(x: 0, y: -1)]
    for dirvec in path:
        for step in 0..<dist * 2:
            pos = pos + dirvec
            result &= pos