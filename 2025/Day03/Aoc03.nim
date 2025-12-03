import std/strutils
import std/algorithm
import std/sequtils
import std/strformat
import std/re
import std/tables
import std/sets
import std/math
import std/bitops

proc prepareInput(filename: string): seq[string] =
    var input: seq[string] = @[]
    for line in lines(filename):
        input.add(line)
    return input


func part1(input: seq[string]): int =
    var sum = 0
    for line in input:
        var maxPos = 0
        var maxChar = line[0]
        for (firstPos, firstDigit) in @line[0..<line.len-1].pairs:
            if maxChar < firstDigit:
                maxChar = firstDigit
                maxPos = firstPos
        var maxChar2 = @line[maxPos + 1]
        for digit in @line[maxPos + 1..<line.len]:
            if maxChar2 < digit:
                maxChar2 = digit
        sum += (&"{maxChar}{maxChar2}").parseInt
    return sum

func part2(input: seq[string]): int =
    var sum = 0
    for line in input:
        var maxPos = -1
        var maxChar = ""
        for digit in 0..<12:
            let startPos = (maxPos + 1)
            #debugEcho startPos..<(line.len-(11 - digit))
            for (firstPos, firstDigit) in @line[startPos..<(line.len-(11 - digit))].pairs:
                if maxChar.len == digit:
                    maxChar.add(firstDigit)
                    maxPos = startPos + firstPos
                if maxChar[digit] < firstDigit:
                    maxChar[digit] = firstDigit
                    maxPos = startPos + firstPos
        #debugEcho maxChar
        sum += maxChar.parseInt
    return sum

when isMainModule:
    #echo prepareInput("Aoc03b.txt")
    #echo $part1(prepareInput("Aoc03b.txt"))
    echo $part2(prepareInput("Aoc03b.txt"))
