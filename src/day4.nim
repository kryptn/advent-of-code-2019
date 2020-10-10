import strutils
import sequtils
import algorithm
import sets
import sugar

proc isValid(i: int): bool =
    result = true
    var digits = i.intToStr
    digits.sort(Ascending)

    if digits != i.intToStr:
        result = false
    if digits.toHashSet.len == digits.len:
        result = false

    # comment for part 1
    var has_double = false
    for d in digits:
        if digits.count(d) == 2:
            has_double = true

    if not has_double:
        result = false


if isMainModule:

    let valid = collect(newSeq):
        for x in 158126..624574:
            if x.isValid:
                x

    echo "day 4 part 1: ", valid.len


