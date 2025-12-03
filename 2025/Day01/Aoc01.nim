import std/strutils
import std/algorithm
import std/sequtils
import std/strformat
import std/re
import std/tables
import std/sets
import std/math
import std/bitops

proc prepareInput(filename: string): seq[int] =
    var input: seq[int] = @[]
    var parsed = @["", ""]
    let reader = re"(L|R)(\d+)"
    for line in lines(filename):
        if line.find(reader, parsed) == -1:
            debugEcho &"Error on {line}"
            continue
        if parsed[0] == "L":
            input.add(-parsed[1].parseInt)
        else:
            input.add(parsed[1].parseInt)
    return input

func part1(input: seq[int]): int =
    var val = 50
    var count = 0
    for change in input:
        val += change
        while val < 0:
            val += 100
        while val > 99:
            val -= 100
        if val == 0:
            count += 1
    return count

func part2(input: seq[int]): int =
    var val = 50
    var count = 0
    for change in input:
        if val == 0 and change < 0:
            count -= 1
            debugEcho &"fixing - on {change}"
        val += change
        while val < 0:
            val += 100
            count += 1
            debugEcho &"left on {val} after {change}"
        while val > 99:
            val -= 100
            count += 1
            debugEcho &"right on {val} after {change}"
            if val == 0:
                count -= 1
                debugEcho &"fixing + on {change}"
        if val == 0:
            count += 1
            debugEcho &"dead on after {change}"
    return count

when isMainModule:
    echo $part1(prepareInput("Aoc01b.txt"))
    echo $part2(prepareInput("Aoc01b.txt"))
