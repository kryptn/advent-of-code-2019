import sequtils
import algorithm
import sugar
import strutils


proc part1(layer: seq[char]) =
    echo "zeros: ", layer.count('0')
    echo "part1: ", layer.count('1') * layer.count('2')


if isMainModule:
    let data = readFile("inputs/day8.txt")

    let knownLayers = data.len / (25*6)

    let layers = data.toSeq.distribute(knownLayers.toInt)

    block p1:
        var sortableLayes = layers
        sort(sortableLayes) do (x, y: seq[char]) -> int:
            result = cmp(x.count('0'), y.count('0'))

        # for layer in layers:
        #     layer.part1
        echo "day 8 part 1: "
        sortableLayes[0].part1

    let final = collect(newSeq):
        for i in 0..<layers[0].len:
            var thisPixel = "x"
            for j in 0..<layers.len:
                if layers[j][i] != '2' and thisPixel == "x":
                    thisPixel = if layers[j][i] == '1': "." else: " "
            thisPixel


    let finalImage = final.distribute(6)
    echo "\npart 2:"
    for row in finalImage:
        echo row.join()






