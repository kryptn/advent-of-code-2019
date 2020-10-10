import intcode/machine
import algorithm
import sugar
import math

proc runWithPhases(phaseSettings: seq[int]): int =
    var input = 0

    for setting in phaseSettings:
        var machine = NewMachineFromFile("inputs/day7.txt")
        machine.push(setting)
        machine.push(input)
        machine.runUntilHalt
        input = machine.pop()

    return input

proc runWithFeedback(phaseSettings: seq[int]): int =
    var machines = collect(newSeq):
        for setting in phaseSettings:
            var m = NewMachineFromFile("inputs/day7.txt")
            m.push(setting)
            m

    machines[0].push(0)

    proc dumpCurrents(): string =
        let currents = collect(newSeq):
            for machine in machines:
                machine.current
        result = repr(currents)


    # echo "\n\nStarting State: ", dumpCurrents()

    while true:
        for i in 0..<machines.len:
            machines[i].runUntilHasNewInput
            machines[(i+1).floorMod(machines.len)].push(machines[i].outputs[^1])
        if machines[^1].isHalt:
            result = machines[^1].outputs[^1]
            break

    # echo "final: \n\n", dumpCurrents()



if isMainModule:
    var phases = @[0, 1, 2, 3, 4]
    var longestSetting = 0
    while true:
        let power = runWithPhases(phases)
        if power > longestSetting:
            longestSetting = power
        if not phases.nextPermutation():
            break

    echo "day 7 part 1: ", longestSetting

    var longestSetting2 = 0
    var phases2 = @[5, 6, 7, 8, 9]
    while true:
        let power = runWithFeedback(phases2)
        if power > longestSetting2:
            longestSetting2 = power
        if not phases2.nextPermutation():
            break

    echo "day 7 part 2: ", longestSetting2
