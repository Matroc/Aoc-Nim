import std/strutils
import std/algorithm
import std/sequtils


let
    input: string = readFile("Aoc01b.txt")

var 
    s1, s2: seq[int]

proc prepareInput =
    for line in input.splitLines():
        let s: seq[string] = line.splitWhitespace()
        s1.add(s[0].parseInt)
        s2.add(s[1].parseInt)
    s1.sort
    s2.sort

proc part1 = 
    var diffsum: int = 0
    for i in 0..<s1.len:
        diffsum += abs(s1[i].int - s2[i].int)
    echo diffsum

proc part2 = 
    var sumsum: int = 0
    for i in 0..<s1.len:
        sumsum += s1[i] * s2.count(s1[i])
    echo sumsum

when isMainModule:
    prepareInput()
    part1()
    part2()