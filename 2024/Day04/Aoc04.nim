import std/strutils
import std/algorithm
import std/sequtils
import std/re


let
    input: string = readFile("Aoc04b.txt")

proc prepareInput(): seq[seq[char]] =
    for line in input.splitLines:
        result.add(@line)
    return result

let
    inp = prepareInput()
    searchWord = @"XMAS"
    dir: seq[tuple[x: int, y:int]] = @[(1, 0), (1, 1), (0, 1), (1, -1), (-1, 0), (-1, -1), (0, -1), (-1, 1)]
    yMax = inp.len - 1
    xMax = inp[yMax].len - 1

converter range(s: seq) :Slice[int] = return s.low..<s.high

proc part1 = 
    var count = 0
    for y in 0..yMax:
        for x in 0..xMax:
                for direction in dir:
                    for i in 0..<searchWord.len:
                        let
                            sx = x + i * direction.x
                            sy = y + i * direction.y
                        if sy notin inp or sx notin inp[sy] or inp[sy][sx] != searchWord[i]:
                            break
                        if i == searchWord.len - 1:
                            count += 1
    echo count

proc part2 = 
    var count = 0
    for y in 1..<yMax:
        for x in 1..<xMax:
            if inp[y][x] != 'A':
                continue
            var diagCount = 0
            if inp[y-1][x-1] == 'M' and inp[y+1][x+1] == 'S':
                diagCount += 1
            elif inp[y-1][x-1] == 'S' and inp[y+1][x+1] == 'M':
                diagCount += 1
            if inp[y-1][x+1] == 'M' and inp[y+1][x-1] == 'S':
                diagCount += 1
            elif inp[y-1][x+1] == 'S' and inp[y+1][x-1] == 'M':
                diagCount += 1
            if diagCount > 1:
                count += 1
    echo count

when isMainModule:
    part1()
    part2()