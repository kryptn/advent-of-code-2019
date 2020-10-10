import macros
import sugar
import strutils


macro input(body: untyped): untyped =
    echo astGenRepr body

    for child in body:
        echo child.repr.split("=>")

    return quote do:
        echo "something"

if isMainModule:
    input:
        10 ORE => 10 A
        1 ORE => 1 B
        7 A, 1 B => 1 C
        7 A, 1 C => 1 D
        7 A, 1 D => 1 E
        7 A, 1 E => 1 FUEL