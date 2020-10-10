import sequtils
import tables
import os

import intcode/machine
import coord


type Screen = Table[Coord, int]



proc getPixel*(s: Screen, pixel: Coord): int =
    if not s.hasKey(pixel):
        return 0
    return s[pixel]

proc `$`(s: Screen): string =

    var maxY: int
    var maxX: int
    for key in s.keys:
        if key.x > maxX:
            maxX = key.x
        if key.y > maxY:
            maxY = key.y

    result &= "Score: " & $s.getPixel(Coord(x: -1, y: 0)) & "\n\n"
    for y in 0..maxY:
        for x in 0..maxX:
            let c = Coord(x: x, y: y)
            let p = s.getPixel(c)
            if p > 4:
                result &= $p
            else:
                let pv = case s.getPixel(c):
                    of 0: ' '
                    of 1: 'W'
                    of 2: 'b'
                    of 3: '_'
                    of 4: 'o'
                    else: ' '
                result &= pv
        result &= '\n'


proc getCharCoord(s: Screen, pv: int): Coord =
    result = Coord(x: -1, y: -1)
    for pair in s.pairs:
        let (coord, value) = pair
        if value == pv:
            return coord

proc hasChar(s: Screen, pv: int): bool =
    let cc = s.getCharCoord(pv)
    return cc != Coord(x: -1, y: -1)


if isMainModule:

    let arcadeBase = NewMachineFromFile("inputs/day13.txt")

    var arcade = arcadeBase
    var screen: Screen = initTable[Coord, int]()

    var pushValue = 0
    while true:
        arcade.runOutputs(3)

        if screen.hasChar(3) and screen.hasChar(4):
            let ballPos = screen.getCharCoord(4)
            let paddlePos = screen.getCharCoord(3)
            echo ballpos, paddlepos
            pushValue = cmp(ballpos.x, paddlepos.x)
        if arcade.current.inputs.len < 1:
            arcade.push(pushValue)
        if arcade.isHalt:
            break
        screen[Coord(x: arcade.pop(), y: arcade.pop())] = arcade.pop()
        echo "push value: ", pushValue
        echo screen, "\n\n\n"
        sleep 10

    # var blocks: int
    # for value in screen.values:
    #     if value == 2:
    #         blocks += 1
    # echo "day 13 part 1: ", blocks
