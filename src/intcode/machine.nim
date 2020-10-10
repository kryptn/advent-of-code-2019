import sequtils
import strutils
import strformat
import bitops
import math
import os
import tables

import state
import interp

type
    Machine* = seq[State]

proc previous*(m: Machine): State =
    return m[^2]

proc current*(m: Machine): State =
    return m[^1]

proc outputs*(m: Machine): seq[int] =
    return m.current.outputs


proc NewMachine*(input: seq[int]): Machine =
    var firstMem = initTable[int, int]()
    for i, val in input:
        firstMem[i] = val
    let s = EmptyState()
    let state = newStateWith(s):
        memory = firstMem
    return @[state,]


proc NewMachineFromFile*(filename: string): Machine =
    let inp = readFile(filename).strip()
    let firstState = inp.split(",").map(parseInt)
    return NewMachine(firstState)



proc isHalt*(m: Machine): bool =
    m.current.opcode.floorMod(100) == 99



proc nextState*(s: State): State =
    let inst = s.opcode.getInstruction
    return inst(s)

proc nextState*(m: Machine): State =
    return m.current.nextState

proc runUntilHalt*(m: var Machine) =
    # echo m.current, "\n\n\n\n"
    # sleep 150

    while not m.isHalt:
        m.add(m.nextState)
        # echo m.current, "\n\n\n\n"
        # sleep 150

proc runUntilHasNewInput*(m: var Machine) =
    while true:
        m.add(m.nextState)

        if m.isHalt:
            break

        if m.current.outputs.len > m.previous.outputs.len:
            break

proc runOutputs*(m: var Machine, n: int) =
    let startOutputs = m.current.outputs.len
    while m.outputs.len < startOutputs + n:
        m.runUntilHasNewInput
        if m.isHalt:
            break



proc push*(m: var Machine, i: int) =
    m.add(m.current.push(i))

proc pop*(m: var Machine): int =
    let popped = m.current.pop()
    m.add(popped[0])
    result = popped[1]

proc replace*(m: var Machine, pos, value: int) =
    m.add(m.current.replace(pos, value))

proc getAddress*(m: var Machine, pos: int): int =
    echo "getting addr ", pos
    m.current.getAddress(pos, true)