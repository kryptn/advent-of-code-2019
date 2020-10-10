import intcode/machine
import intcode/state
import macros

if isMainModule:

    var m = NewMachineFromFile("inputs/day9.txt")
    m.push(1)

    m.runUntilHalt()

    echo m.outputs
    echo m.current

    var m2 = NewMachineFromFile("inputs/day9.txt")
    m2.push(2)

    m2.runUntilHalt()

    echo m2.outputs
    echo len(m2)
    # echo m2.current