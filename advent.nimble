# Package

version       = "0.1.0"
author        = "kryptn"
description   = "Advent of Code 2019"
license       = "MIT"
srcDir        = "src"
binDir        = "bin"
installExt    = @["nim"]
bin           = @[]

for file in listFiles(srcDir):
    if "day" in file:
        bin.add file[4..^5]


# Dependencies
requires "nim >= 1.2.6"
