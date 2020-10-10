import macros
import tables
import math

type
    State* = ref object of RootObj
        pos*: int
        base*: int
        memory*: Table[int, int]
        inputs*: seq[int]
        outputs*: seq[int]

proc `$`*(s: State): string

proc getAddress*(s: State, address: int, debug: bool = false): int =
    if not s.memory.hasKey(address):
        if debug:
            echo "state did not have addr ", address
        return 0
    if debug:
        echo "state had address ", address, " and it's ", s.memory[address]
    return s.memory[address]

proc highAddr(s: State): int =
    result = 0
    for key in s.memory.keys:
        if key > result:
            result = key

proc highVal(s: State): int =
    var h = 0
    for val in s.memory.values:
        if val > result:
            h = val
    result = h.float32.log10.toInt


proc padStr(s: string, to: int, v: string = " "): string =
    result = s
    while result.len < to:
        result = v & result

proc `$`*(s: State): string =
    let width = 16
    var newRow = true
    let highestVal = highVal(s)

    result &= "pos: " & $s.pos & "   base: " & $s.base & "\n"
    result &= "inputs: " & $s.inputs & "\n"
    result &= "outputs: " & $s.outputs & "\n"

    for i in 0..highAddr(s):
        if i.floorMod(width) == 0:
            result &= "\n"
            newRow = true
        if newRow:
            if s.pos < i and s.pos >= i-width:
                result &= padStr(">>>", highestVal) & "\t"
                for j in i-width..i:
                    if j == s.pos:
                        result &= padStr("^", highestVal+5)
                    else:
                        result &= padStr(" ", highestVal+5)
                result &= "\n"
            result &= padStr($i, highestVal) & "\t"
            newRow = false
        result &= ($s.getAddress(i, true)).padStr(highestVal+5)



proc EmptyState*(): State =
    State(pos: 0, base: 0, memory: initTable[int, int](), inputs: @[], outputs: @[])


proc opcode*(s: State): int =
    return s.getAddress(s.pos)


proc getIdent(args: NimNode, name: string): NimNode =
    result = newDotExpr(newIdentNode("s"), newIdentNode(name))
    for node in args:
        node.expectKind nnkAsgn
        if node[0].repr == name:
            result = node[1]

macro newStateWith*(s: State, args: untyped): State =
    let pos = args.getIdent("pos")
    let base = args.getIdent("base")
    let memory = args.getIdent("memory")
    let inputs = args.getIdent("inputs")
    let outputs = args.getIdent("outputs")

    result = quote do:
        State(
            pos: `pos`,
            base: `base`,
            memory: `memory`,
            inputs: `inputs`,
            outputs: `outputs`,
        )

    # echo result.treeRepr

proc replace*(s: State, pos, newValue: int): State =
    var newMemory = s.memory
    newMemory[pos] = newValue
    result = newStateWith(s):
        memory = newMemory

proc push*(s: State, i: int): State =
    let newinputs = s.inputs & i
    result = newStateWith(s):
        inputs = newinputs

proc pop*(s: State): (State, int) =
    let ns = newStateWith(s):
        outputs = s.outputs[1..^1]

    result = (ns, s.outputs[0])


proc hasOutput*(s: State): bool =
    s.outputs.len > 0