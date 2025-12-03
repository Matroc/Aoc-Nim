import std/strutils
import std/algorithm
import std/sequtils
import std/strformat
import std/re
import std/tables
import std/sets
import std/math
import std/bitops

type xy = tuple[x:int, y:int]

func `+`(a:xy, b:xy): xy = (a.x + b.x, a.y + b.y)
func `-`(a:xy, b:xy): xy = (a.x - b.x, a.y - b.y)
func inBounds(c:xy, map:seq[seq]):bool = c.y in 0..<map.len and c.x in 0..<map[0].len

proc prepareInput(filename: string): seq[seq[char]] =
    var input: seq[seq[char]] = @[]
    for line in lines(filename):
        input.add(@line)
    return input

func part1(input: seq[seq[char]]): int =
    var towers: Table[char, seq[xy]] = initTable[char, seq[xy]]()
    for (y, line) in input.pairs:
        for (x, c) in line.pairs:
            if c != '.':
                if not towers.hasKey(c):
                    towers[c] = @[]
                towers[c].add((x, y))
    var res: seq[xy] = @[]
    for (towerType, ts) in towers.pairs:
        for pairs in @[ts].cycle(2).product():
            #debugEcho &"{pairs} for {towerType} with {ts}"
            if pairs[0] == pairs[1]:
                continue
            let dist = pairs[0] - pairs[1]
            let dest = pairs[0] + dist
            if not dest.inBounds(input):
                #debugEcho &"{dest} out of bounds"
                continue
            if res.find(dest) == -1:
                #debugEcho &"{dest} is new"
                res.add(dest)
    return res.len

func part2(input: seq[seq[char]]): int =
    var towers: Table[char, seq[xy]] = initTable[char, seq[xy]]()
    for (y, line) in input.pairs:
        for (x, c) in line.pairs:
            if c != '.':
                if not towers.hasKey(c):
                    towers[c] = @[]
                towers[c].add((x, y))
    var res: seq[xy] = @[]
    for (towerType, ts) in towers.pairs:
        for pairs in @[ts].cycle(2).product():
            #debugEcho &"{pairs} for {towerType} with {ts}"
            if pairs[0] == pairs[1]:
                continue
            let dist = pairs[0] - pairs[1]
            var dest = pairs[0]
            while dest.inBounds(input):
                #debugEcho &"{dest} in bounds"
                if res.find(dest) == -1:
                    #debugEcho &"{dest} is new"
                    res.add(dest)
                dest = dest + dist
    return res.len

when isMainModule:
    echo $part1(prepareInput("Aoc08b.txt"))
    echo $part2(prepareInput("Aoc08b.txt"))
