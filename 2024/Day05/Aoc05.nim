import std/strutils
import std/algorithm
import std/sequtils
import std/strformat
import std/re
import std/tables
import std/sets
import std/math


let
    inputRules: string = readFile("Aoc05b.txt")
    inputPages: string = readFile("Aoc05b2.txt")

var
    second: Table[int, seq[int]] = initTable[int, seq[int]]()
    pages: seq[seq[int]] = @[]
    baddies: seq[seq[int]] = @[]

proc prepareInput() =
    for line in inputRules.splitLines:
        let rule = line.split('|').map(parseInt)
        if not second.hasKey(rule[1]):
            second[rule[1]] = @[]
        second[rule[1]].add(rule[0])
    for line in inputPages.splitLines:
        pages.add(line.split(",").map(parseint))

proc part1 = 
    var sum = 0
    for pgs in pages:
        var
            found: seq[int] = @[]
            forbidden: seq[int] = @[]
            mid: int = pgs[(pgs.len / 2).floor.int]
            bad = false
        for p in pgs:
            if p in forbidden:
                bad = true
                break
            if p notin found:
                found.add(p)
                for s in second.getOrDefault(p, @[]):
                    if s notin found and s notin forbidden:
                        forbidden.add(s)
        if not bad:
            sum += mid
            echo $pgs
        else:
            baddies.add(pgs)
    echo sum

proc part2 =
    var sum = 0
    for pgs1 in baddies:
        var pgs = pgs1
        var newPgs: seq[int] = @[]
        while pgs.len > 0:
            var bad = false
            for p in pgs:
                bad = false
                for s in second.getOrDefault(p, @[]):
                    if s in pgs:
                        bad = true
                        break
                if not bad:
                    newPgs.add(p)
                    pgs.delete(pgs.find(p))
                    break
            if bad:
                echo &"uh oh, this one can't be resolved: {pgs}"
        sum += newPgs[(newPgs.len / 2).floor.int]
    echo sum

when isMainModule:
    prepareInput()
    part1()
    part2()