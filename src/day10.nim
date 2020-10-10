import sugar
import tables
import strutils
import sequtils
import hashes
import math
import complex
import algorithm
import sets


type Coord = object
    x, y: int

type Laser = object
    original: Coord
    translated: Coord
    polar: tuple[r, phi: float]


proc `$`(l: Laser): string =
    result &= "{\n"
    result &= "    original: " & $l.original & "\n"
    result &= "    translated: " & $l.translated & "\n"
    result &= "    polar: " & $l.polar & "\n}\n"


proc hash(c: Coord): Hash =
    var h: Hash = 0
    h = h !& (c.x + 10*10000)
    h = h !& c.y
    result = !$h

proc `+`(c:Coord, o:Coord): Coord =
    Coord(x: c.x + o.x, y: c.y + o.y)

proc `-`(c: Coord, o: Coord): Coord =
    Coord(x: c.x - o.x, y: c.y - o.y)

proc squareAround(c: Coord, dist: int): seq[Coord] =
    var pos = c + Coord(x: -dist, y: -dist)

    const path = @[Coord(x: 1, y: 0), Coord(x: 0, y: 1), Coord(x: -1, y: 0), Coord(x: 0, y: -1)]
    for dirvec in path:
        for step in 0..<dist * 2:
            pos = pos + dirvec
            result &= pos


proc getAsteroids(rawAstroids: string): Table[Coord, bool] =
    var x = 0
    var y = 0
    for line in rawAstroids.splitLines:
        for c in line:
            result[Coord(x: x, y: y)] = c == '#'
            x += 1
        y += 1
        x = 0

proc getCandidates(asteroids: Table[Coord, bool], subject: Coord, dist: int): seq[Coord] =
    let square = squareAround(subject, dist)
    for candidate in square:
        if asteroids.hasKey(candidate) and asteroids[candidate]:
            result &= candidate


proc showField(asteroids: Table[Coord, bool], subject: Coord): string =
    var cursor = Coord(x: 0, y: 0)
    let over = Coord(x: 1, y: 0)

    result &= "subject: " & $subject & "\n\n"

    while true:
        if asteroids.hasKey(cursor):
            if cursor == subject:
                result &= '*'
            elif asteroids[cursor]:
                result &= '#'
            else:
                result &= '.'
            cursor = cursor + over
        else:
            cursor = Coord(x: 0, y: cursor.y + 1)
            result &= '\n'
            if not asteroids.hasKey(cursor):
                break



proc reduce(c: Coord): Coord =
    result = c
    for n in 1..high(int):
        # echo "checking n: ", n
        if (c.x == 0 or n > c.x.abs) and (c.y == 0 or n > c.y.abs):
            # echo "breaking"
            break
        if c.x.abs.floorMod(n) == 0 and c.y.abs.floorMod(n) == 0:
            # echo "reducing"
            result = Coord(x: c.x.floorDiv(n), y: c.y.floorDiv(n))

    # echo "before reduction: ", c
    # echo "after reduction: ", result, "\n"

proc countVisible(asteroids: Table[Coord, bool], subject: Coord): int =
    var field = asteroids
    # echo "\n\nwe're at ", subject
    for dist in 1..high(int):
        if subject.squareAround(dist).allIt(not field.hasKey(it)):
            break

        let candidates = field.getCandidates(subject, dist)
        for candidate in candidates:
            # echo "we can see ", candidate
            let vec = reduce(candidate - subject)
            # echo candidate, " is ", vec, " from us "
            var path = candidate + vec
            while field.hasKey(path):
                # echo "removing ", path, "from the list"
                field[path] = false
                path = path + vec

    result -= 1 # self
    for val in field.values:
        if val:
            result += 1

    # echo field.showField(subject)

# proc toPolar


proc sortAsteroids(a: var seq[Laser]) =
    a.sort do (x, y: Laser) -> int:
        result = cmp(y.polar.phi, x.polar.phi)
        if result == 0:
            result = cmp(x.polar.r, y.polar.r)

    while a[^1].translated.x == 0:
        a.rotateLeft -1


if isMainModule:

    let input = readFile("inputs/day10.txt")
    let asteroids = getAsteroids(input)
    # echo asteroids

    var maxSeen = 0
    var bestPos = Coord(x: -1, y: -1)
    for pairs in asteroids.pairs:
        let (c, v) = pairs
        if v:
            let cansee = countVisible(asteroids, c)
            if cansee > maxSeen:
                bestPos = c
                maxSeen = cansee

    echo maxSeen, bestPos


    echo bestPos - bestPos

    var translated = collect(newSeq):
        for pairs in asteroids.pairs:
            let (c, v) = pairs
            if v:
                let t = c - bestPos
                if t.x == 0 and t.y == 0:
                    continue
                let com = complex(t.x.toFloat, t.y.toFloat)
                var p = com.polar
                if p.phi > 0:
                    p.phi = -2 * PI + p.phi
                p.phi -= 0.5*PI
                if p.phi < -2 * PI:
                    p.phi += 2 * PI
                Laser(
                    original: c,
                    translated: t,
                    # rotated: rot,
                    polar: p
                )

    translated.sortAsteroids

    var laserOrder: seq[Laser]

    var thisRound = translated
    var nextRound: seq[Laser]
    var visitedThisRound: seq[float]

    var n = 1
    while thisRound.len > 0:
        echo "round ", n
        for asteroid in thisRound:
            if asteroid.polar.phi in visitedThisRound:
                echo "have seen ", asteroid.polar.phi, " this round, adding to next"
                nextRound &= asteroid
            else:
                echo "adding ", asteroid.translated, " to list"
                laserOrder &= asteroid
                visitedThisRound.add(asteroid.polar.phi)

        visitedThisRound = @[]
        echo "need to circle back to ", nextRound.len, " asteroids"

        if nextRound.len == 1:
            break

        thisRound = nextRound
        thisRound.sortAsteroids
        nextRound = @[]
        n += 1



    echo laserOrder

    echo laserOrder[199]

    # echo squareAround(Coord(x: 2, y: 2), 1)

    # let origin = Coord(x: 0, y: 0)
    # let subject = Coord(x: 1, y: 1)
    # let vec = subject - origin
    # let nsub = subject + vec

    # echo origin
    # echo subject
    # echo vec
    # echo nsub



    # echo Coord(x: 0, y: 2).reduce

    # #echo -6.floorMod(2)


