import os

let verbose* =
    if "--verbose" in commandLineParams():
        true
    elif "-v" in commandLineParams():
        true
    else:
        false
