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
type status = enum moved, exit, loop

var
    map: seq[seq[char]] = @[]
    pos:xy
    dir:xy = (x: 0, y: -1)

proc rotateRight(d: var xy) =
    if d.y == -1:
        d = (1, 0)
    elif d.y == 1:
        d = (-1, 0)
    elif d.x == -1:
        d = (0, -1)
    else:
        d = (0, 1)

proc `+`(a:xy, b:xy): xy = (a.x + b.x, a.y + b.y)
proc `+=`(a:var xy, b:xy) = a = a+b

proc dirBit(d: xy): char =
    if d.y == -1:
        return 1.char
    elif d.y == 1:
        return 2.char
    elif d.x == -1:
        return 4.char
    else:
        return 8.char

proc applyDirbit(c: var char, d: xy) =
    if c == '.' or c == '^':
        c = dirBit(d)
    c = bitor(c.byte, dirBit(d).byte).char

proc isLoop(c: char, d: xy): bool =
    if c.byte > 16:
        return false
    return bitand(c.byte, dirBit(d).byte) != 0

proc prepareInput(filename: string) =
    map = @[]
    dir = (x: 0, y: -1)
    for line in lines(filename):
        var row:seq[char] = @[]
        for c in line:
            if c == '^':
                pos = (x: row.len, y: map.len)
            row.add(c)
        map.add(row)

proc move(): status = 
    map[pos.y][pos.x].applyDirbit(dir)
    var p1 = pos + dir
    if p1.y notin 0..<map.len or p1.x notin 0..<map[0].len:
        return exit
    if map[p1.y][p1.x].isloop(dir):
        return loop
    while map[p1.y][p1.x] == '#':
        rotateRight(dir)
        map[pos.y][pos.x].applyDirbit(dir)
        p1 = pos + dir
        if p1.y notin 0..<map.len or p1.x notin 0..<map[0].len:
            return exit
        if map[p1.y][p1.x].isloop(dir):
            return loop
    pos = p1
    return moved

proc printMap() =
    for y in 0..<map.len:
        for x in 0..<map[y].len:
            if map[y][x].byte <= 16:
                stdout.write 'X'
            else:
                stdout.write map[y][x]
        echo " "
    echo &"h: {map.len} w:{map[0].len}"

proc part1 =
    prepareInput("Aoc06b.txt")
    while move() == moved:
        continue
    echo sum(map.mapIt(it.countIt(it.byte <= 16)))

proc part2 =
    prepareInput("Aoc06b.txt")
    let bck = map
    let startBck = pos
    let startDir = dir
    var count = 0
    for y in 0..<map.len:
        for x in 0..<map[y].len:
            if map[y][x] != '.':
                continue
            map[y][x] = '#'
            var state = move()
            while state == moved:
                state = move()
            #printMap()
            if state == loop:
                count += 1
            map = bck
            pos = startBck
            dir = startDir
    echo count
    


when isMainModule:
    part1()
    part2()