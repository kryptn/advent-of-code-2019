import intcode/machine
import intcode/state

if isMainModule:
    var part1 = NewMachineFromFile("inputs/day2.txt")
    part1.replace(1, 12)
    part1.replace(2, 2)
    part1.runUntilHalt()
    echo "day 2 part 1: ", part1.getAddress(0), "\n\n", part1.current


    # block rep:
    #     for x in 0..100:
    #         for y in 0..100:
    #             var m = NewMachineFromFile("inputs/day2.txt")
    #             # echo x, y
    #             m.replace(1, x)
    #             m.replace(2, y)
    #             m.runUntilHalt()
    #             if m.getAddress(0) == 19690720:
    #                 echo "day 2 part 2: ", m.getAddress(1) * 100 + m.getAddress(2)
    #                 break rep




