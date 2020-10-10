
import sequtils
import sugar
import hashes

type
    Vector = object
        x, y, z: int
    Body = object
        position: Vector
        velocity: Vector

proc hash(b: Body): Hash =
    var s = "p:" & $b.position.x & $b.position.y & $b.position.z
    s &= "v:" & $b.velocity.x & $b.velocity.y & $b.velocity.z
    result = s.hash


proc `+`(v: Vector, o: Vector): Vector =
    Vector(
        x: v.x + o.x,
        y: v.y + o.y,
        z: v.z + o.z,
    )

proc `$`(b: Body): string =
    result &= "position: " & $b.position & "\nvelocity: " & $b.velocity & "\n\n"

proc ZeroVel(): Vector =
    Vector(x: 0, y: 0, z: 0)

proc BodyWithPosition(pos: Vector): Body =
    Body(
        position: pos,
        velocity: ZeroVel()
    )


let inputBodies = @[
    BodyWithPosition(Vector(x: 14, y: 9, z: 14)),
    BodyWithPosition(Vector(x: 9, y: 11, z: 6)),
    BodyWithPosition(Vector(x: -6, y: 14, z: -4)),
    BodyWithPosition(Vector(x: 4, y: -4, z: -3))
]

let testBodies = @[
    BodyWithPosition(Vector(x: -1, y: 0, z: 2)),
    BodyWithPosition(Vector(x: 2, y: -10, z: -7)),
    BodyWithPosition(Vector(x: 4, y: -8, z: 8)),
    BodyWithPosition(Vector(x: 3, y: 5, z: -1)),
]





proc influence(a, b: Body): Vector =
    # echo "a: \n", a
    # echo "b: \n", b
    # echo cmp(a.position.x, b.position.x)

    result = Vector(
        x: cmp(a.position.x, b.position.x) * -1,
        y: cmp(a.position.y, b.position.y) * -1,
        z: cmp(a.position.z, b.position.z) * -1
    )
    # echo "result: ", result, "\n\n"

proc applyGravity(bodies: seq[Body]): seq[Body] =
    let velocities = collect(newSeq):
        for i in 0..<bodies.len:
            var delta = ZeroVel()
            for j in 0..<bodies.len:
                if i != j:
                    # echo "comparing ", i, " and ", j
                    delta = delta + influence(bodies[i], bodies[j])
            delta

    result = collect(newSeq):
        for pairs in zip(bodies, velocities):
            let (oldBody, velocityDelta) = pairs
            Body(
                position: oldBody.position,
                velocity: oldBody.velocity + velocityDelta,
            )


proc applyVelocity(bodies: seq[Body]): seq[Body] =
    result = collect(newSeq):
        for body in bodies:
            Body(
                position: body.position + body.velocity,
                velocity: body.velocity,
            )

proc timeStep(bodies: seq[Body]): seq[Body] =
    result = bodies.applyGravity.applyVelocity

proc energy(vec: Vector): int =
    return vec.x.abs + vec.y.abs + vec.z.abs

proc energy(body: Body): int =
    return body.position.energy * body.velocity.energy

proc energy(bodies: seq[Body]): int =
    for body in bodies:
        result += body.energy



if isMainModule:
    # let left = Body(
    #     position: Vector(x: 2, y: 1, z: 0),
    #     velocity: Vector(x: 0, y: 0, z: 0),
    # )
    # let right = Body(
    #     position: Vector(x: 0, y: 1, z: 2),
    #     velocity: Vector(x: 0, y: 0, z: 0),
    # )

    # echo influence(left, right)
    # echo influence(right, left)


    var bodies = inputBodies

    for i in 0..<1000:
        bodies = bodies.timeStep
        # echo bodies

    echo "day 12 part 1: ", bodies.energy

    var seen: seq[Hash]
    var bodiees = inputBodies
    for i in 0..high(int):
        if bodiees.hash in seen:
            echo i
            break
        seen.add(bodiees.hash)
        bodiees = bodiees.timeStep


    # takes too long.
    # https://adventofcode.com/2019/day/12#part2
    echo bodiees.len

