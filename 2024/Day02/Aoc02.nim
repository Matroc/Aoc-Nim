import std/strutils
import std/algorithm
import std/sequtils


let
    input: string = readFile("Aoc02b.txt")

var 
    s: seq[seq[int]]

proc prepareInput =
    for line in input.splitLines():
        s.add line.splitWhitespace().mapIt(it.parseInt)

func isSafe(s: seq[int]) : bool =
    var safe = true
    var prev = s[0]
    var asc: bool = prev < s[1]
    for j in 1..<s.len:
        let diff = prev - s[j]
        if diff < 0 != asc:
            safe = false
            break
        if abs(diff) < 1 or abs(diff) > 3:
            safe = false
            break
        prev = s[j]
    return safe

proc part1 = 
    var safeCount: int = 0
    for i in 0..<s.len:
        if isSafe(s[i]):
            safeCount += 1
    echo safeCount

proc part2 = 
    var safeCount: int = 0
    for i in 0..<s.len:
        for j in 0..<s[i].len:
            var sd = s[i]
            sd.delete(j)
            if isSafe(sd):
                safeCount += 1
                break
    echo safeCount

when isMainModule:
    prepareInput()
    part1()
    part2()