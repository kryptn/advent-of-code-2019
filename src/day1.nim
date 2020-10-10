import os
import math
import strutils
import sugar
import common

proc fuelCost(mass: int): int =
    floor(mass / 3).int - 2


proc readNumbers(filename: string): seq[int] =
    for line in filename.lines:
        let cleaned = line.strip
        if cleaned != "":
            result.add(cleaned.parseInt)

when isMainModule:

    let masses = readNumbers("inputs/day1.txt")
    var fuelCosts = collect(newSeq):
        for m in masses:
            m.fuelCost

    let total = sum(fuelCosts)
    echo "part 1: ", total

    if verbose:
        echo repr fuelCosts

    for i in 0..high(int):
        if i >= fuelCosts.len:
            break
        let thisFuelCost = fuelCosts[i].fuelCost
        if thisFuelCost > 0:
            fuelCosts.add(thisFuelCost)


    let total2 = sum(fuelCosts)
    echo "part 2: ", total2

    if verbose:
        echo repr fuelCosts



