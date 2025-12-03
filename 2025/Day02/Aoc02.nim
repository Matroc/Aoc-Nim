import std/strutils
import std/algorithm
import std/sequtils
import std/strformat
import std/re
import std/tables
import std/sets
import std/math
import std/bitops

proc prepareInput(filename: string): seq[tuple[fr:string, to:string]] =
    var input: seq[tuple[fr:string, to:string]] = @[]
    for line in lines(filename):
        for pair in line.split(','):
            let splitPair = pair.split('-')
            if splitPair.len == 2:
                input.add((splitPair[0], splitPair[1]))
    return input

func isValid(val: string): bool =
    if val[0] == '0':
        #debugEcho &"{val} starts with 0 is invalid"
        return false
    if val.len mod 2 == 0:
        let mid = (val.len / 2).floor.int
        for i in 0..<mid:
            if val[i] != val[i + mid]:
                #debugEcho &"{val} not repeated valid"
                return true
        #debugEcho &"{val} repeated invalid"
        return false
    #debugEcho &"{val} default valid"
    return true

func isValid2(val: string): bool =
    if val[0] == '0':
        #debugEcho &"{val} starts with 0 is invalid"
        return false
    for lenSplit in 1..(val.len / 2).floor.int:
        if val.len mod lenSplit == 0:
            var diff = false
            for i in 0..<lenSplit:
                #debugEcho &"cmp range {1..<(val.len / lenSplit).round.int}"
                for cmp in 1..<(val.len / lenSplit).round.int:
                    if val[i] != val[i + cmp * lenSplit]:
                        #debugEcho &"{val} not repeated valid"
                        diff = true
                        break
                if diff:
                    break
            if not diff:
                #debugEcho &"{val} repeated {lenSplit} times invalid"
                return false
    #debugEcho &"{val} default valid"
    return true


func part1(input: seq[tuple[fr:string, to:string]]): int =
    debugEcho &"{input}"
    var sum = 0
    for i in input:
        for id in (i.fr.parseInt)..(i.to.parseInt):
            if not ($id).isValid:
                sum += id
    return sum

func part2(input: seq[tuple[fr:string, to:string]]): int =
    debugEcho &"{input}"
    var sum = 0
    for i in input:
        for id in (i.fr.parseInt)..(i.to.parseInt):
            if not ($id).isValid2:
                sum += id
    return sum

when isMainModule:
    #echo $part1(prepareInput("Aoc02b.txt"))
    echo $part2(prepareInput("Aoc02b.txt"))
