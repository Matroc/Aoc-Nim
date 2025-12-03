import std/strutils
import std/algorithm
import std/sequtils
import std/strformat
import std/re
import std/tables
import std/sets
import std/math
import std/bitops

var
    input: seq[tuple[res:int, vals: seq[int]]]

func plus(a:int, b:int):int = a + b
func mul(a:int, b:int):int = a * b
func con(a:int, b:int):int = ($a & $b).parseInt

let
    ops = {"+":plus, "*":mul}.toTable
    opsIdx = ops.keys.toSeq

    ops2 = {"+":plus, "*":mul, "||":con}.toTable
    opsIdx2 = ops2.keys.toSeq


proc prepareInput(filename: string) =
    input = @[]
    for line in lines(filename):
        let l = line.split(':')
        input.add((res: l[0].parseInt, vals: l[1].splitWhitespace.map(parseInt)))

proc part1 =
    prepareInput("Aoc07b.txt")
    var sum = 0
    for (res, vals) in input:
        var possibilities = @[opsIdx].cycle(vals.len - 1).product
        if vals.len == 2:
            possibilities = @[@["+"], @["*"]]
        #echo possibilities
        for pos in possibilities:
            var eqVal = vals[0]
            for i in 1..<vals.len:
                eqVal = ops[pos[i - 1]](eqVal, vals[i])
                if eqVal > res:
                    break
            #echo &"{res} == {eqVal} with {pos}"
            if eqVal == res:
                sum += eqVal
                #echo &"{res} = {vals} with {pos}"
                break
    echo sum

proc part2 =
    prepareInput("Aoc07b.txt")
    var sum = 0
    for (res, vals) in input:
        var possibilities = @[opsIdx2].cycle(vals.len - 1).product
        if vals.len == 2:
            possibilities = @[@["+"], @["*"], @["||"]]
        #echo possibilities
        for pos in possibilities:
            var eqVal = vals[0]
            for i in 1..<vals.len:
                eqVal = ops2[pos[i - 1]](eqVal, vals[i])
                if eqVal > res:
                    break
            #echo &"{res} == {eqVal} with {pos}"
            if eqVal == res:
                sum += eqVal
                #echo &"{res} = {vals} with {pos}"
                break
    echo sum

when isMainModule:
    #part1()
    #part2()
    echo $(@[opsIdx].cycle(1).product)
