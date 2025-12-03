import std/strutils
import std/algorithm
import std/sequtils
import std/re


let
    input: string = readFile("Aoc03b.txt")

proc part1 = 
    var mult = ["0","0"]
    let regex = re"mul\((\d+),(\d+)\)"
    var i = 0
    var result = 0
    while i < input.len:
        let found = input.find(regex, mult, i)
        if found == -1:
            break
        result += mult[0].parseInt * mult[1].parseInt
        i = found + 1
    echo result

proc part2 = 
    var mult = ["0","0", "", ""]
    let regex = re"(do(n't)?\(\))|mul\((\d+),(\d+)\)"
    var i = 0
    var result = 0
    var enable = true
    while i < input.len:
        let found = input.find(regex, mult, i)
        if found == -1:
            break
        if mult[0] == "do()":
            enable = true
        elif mult[0] == "don\'t()":
            enable = false
        elif enable:
            result += mult[2].parseInt * mult[3].parseInt
        i = found + 1
    echo result

when isMainModule:
    part1()
    part2()