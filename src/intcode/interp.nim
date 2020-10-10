import strutils
import math
import os
import tables

import state


type Operation* = proc(s: State): State
type Instruction* = proc(opcode: int): Operation

type InstructionMode = enum
    Address
    RelativeAddress
    Immediate
    Relative


proc modeMap(opcode: int): Table[int, InstructionMode] =
    let inst = opcode.floorMod 100
    var parameterModes = opcode.floorDiv 100

    for i in 1..3:
        let thisMode = parameterModes.floorMod 10
        parameterModes = parameterModes.floorDiv 10
        if thisMode == 0:
            result[i] = Address
        elif thisMode == 1:
            result[i] = Immediate
        elif thisMode == 2 and inst == 2:
            result[i] = Relative
        else:
            result[i] = RelativeAddress


proc getWithMode(s: State, mode: InstructionMode, paramOffset: int): int =
    let v = s.getAddress(s.pos + paramOffset)

    result = case mode:
        of Address:
            s.getAddress(s.getAddress(s.pos + paramOffset))
        of RelativeAddress:
            s.getAddress(s.getAddress(s.pos + paramOffset) + s.base)
        of Immediate:
            s.getAddress(s.pos + paramOffset)
        of Relative:
            s.getAddress(s.pos + paramOffset) + s.base

template withMode(opcode: int, body: untyped): untyped =
    let modes = opcode.modeMap

    proc noun(s: State): int =
        # nouns are always pos 1
        s.getWithMode(modes[1], 1)

    proc verb(s: State): int =
        # verbs are always pos 2
        s.getWithMode(modes[2], 2)

    proc dest(s: State, posOffset: int = 3): int =
        # dests are not always 3
        s.getWithMode(modes[posOffset], posOffset)

    body

# template withMode(opcode: int, body: untyped): untyped =

#     var modes = (opcode.floorDiv 100).intToStr
#     while modes.len < 5:
#         modes = "0" & modes

#     proc getParameter(s: State, posOffset: int, forceMode: char = 'x'): int =
#         # echo "modes: ", modes, "   offset: ", posOffset
#         let thisMode = if forceMode != 'x': forceMode else: modes[^posOffset]
#         result = case thisMode:
#             of '0': s.getAddress(s.getAddress(s.pos+posOffset)) # default -- by addr
#             of '1': s.getAddress(s.pos+posOffset) # immediate
#             of '2': s.getAddress(s.getAddress(s.pos+posOffset) + s.base)  # relative
#             of '3': s.getAddress(s.pos+posOffset) + s.base  # relative?
#             else: -1

#     proc noun(s: State, posOffset: int = 1): int =
#         result = s.getParameter(posOffset)
#         # echo "noun ", result

#     proc verb(s: State, posOffset: int = 2): int =
#         result = s.getParameter(posOffset)
#         # echo "verb ", result

#     proc dest(s: State, posOffset: int = 3): int =
#         let mode = if modes[^posOffset] == '2': '3' else: '1'
#         result = s.getParameter(posOffset, forceMode = mode)
#         # echo "dest ", result

#     body


proc Add(s: State): State =
    withMode(s.opcode):
        var nextState = s.memory
        nextState[s.dest] = s.noun + s.verb
        result = newStateWith(s):
            memory = nextState
            pos = s.pos + 4


proc Multiply(s: State): State =
    withMode(s.opcode):
        var nextState = s.memory
        nextState[s.dest] = s.noun * s.verb
        result = newStateWith(s):
            memory = nextState
            pos = s.pos + 4


proc Input(s: State): State =
    withMode(s.opcode):
        var nextState = s.memory
        nextState[s.dest(1)] = s.inputs[0]
        result = newStateWith(s):
            memory = nextState
            pos = s.pos + 2
            inputs = s.inputs[1..^1]


proc Output(s: State): State =
    withMode(s.opcode):
        result = newStateWith(s):
            pos = s.pos + 2
            outputs = s.outputs & s.noun


proc JumpIfTrue(s: State): State =
    withMode(s.opcode):
        let jumping = s.noun != 0
        let nextPos = if jumping: s.verb else: s.pos+3
        result = newStateWith(s):
            pos = nextPos


proc JumpIfFalse(s: State): State =
    withMode(s.opcode):
        let jumping = s.noun == 0
        let nextPos = if jumping: s.verb else: s.pos+3
        result = newStateWith(s):
            pos = nextPos


proc LessThan(s: State): State =
    withMode(s.opcode):
        var nextState = s.memory
        nextState[s.dest] = if s.noun < s.verb: 1 else: 0
        result = newStateWith(s):
            memory = nextState
            pos = s.pos + 4


proc Equals(s: State): State =
    withMode(s.opcode):
        var nextState = s.memory
        nextState[s.dest] = if s.noun == s.verb: 1 else: 0
        result = newStateWith(s):
            memory = nextState
            pos = s.pos + 4


proc AdjustBase(s: State): State =
    withMode(s.opcode):
        result = newStateWith(s):
            base = s.base + s.noun
            pos = s.pos + 2


proc Halt(s: State): State =
    return State(memory: s.memory, pos: s.pos, inputs: s.inputs, outputs: s.outputs)


proc getInstruction*(opcode: int): Operation =
    result = case opcode.floorMod(100):
        of 1: Add
        of 2: Multiply
        of 3: Input
        of 4: Output
        of 5: JumpIfTrue
        of 6: JumpIfFalse
        of 7: LessThan
        of 8: Equals
        of 9: AdjustBase
        of 99: Halt
        else:
            Halt
