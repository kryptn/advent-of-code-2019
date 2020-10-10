import intcode/machine

if isMainModule:
    var part1 = NewMachineFromFile("inputs/day5.txt")
    part1.push(1)
    part1.runUntilHalt
    echo part1[^1].outputs

    var part2 = NewMachineFromFile("inputs/day5.txt")
    part2.push(5)
    part2.runUntilHalt
    echo part2[^1].outputs

    # var testMachine = NewMachineFromFileWithInputs("inputs/day5test3.txt", @[7])
    # testMachine.runUntilHalt
    # echo testMachine[^1].outputs

