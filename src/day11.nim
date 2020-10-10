

import intcode/machine
import coord
import algorithm
import tables

if isMainModule:

    var robot = NewMachineFromFile("inputs/day11.txt")
    var knownCoords = initTable[Coord, bool]()


    var directions = @[Coord(x: 0, y: 1), Coord(x: 1, y: 0), Coord(x: 0, y: -1), Coord(x: -1, y: 0)]

    var robotPos = Coord(x: 0, y: 0)
    knownCoords[robotPos] = true

    proc floorColor(pos: Coord): int =
        if knownCoords.hasKey(pos):
            result = if knownCoords[pos]: 1 else: 0
        else:
            result = 0


    while true:
        robot.push(floorColor(robotPos))


        robot.runUntilHasNewInput()
        robot.runUntilHasNewInput()


        if robot.isHalt:
            break

        knownCoords[robotPos] = if robot.pop() == 1: true else: false
        let dist = if robot.pop() == 1: -1 else: 1
        directions.rotateLeft dist
        robotPos = robotPos + directions[0]


    echo knownCoords.len


    var image = ""
    for y in 0..10:
        for x in 0..50:
            let c = Coord(x: -x, y: -y)
            if floorColor(c) == 1:
                image &= '#'
            else:
                image &= '.'
        image &= '\n'

    echo image

