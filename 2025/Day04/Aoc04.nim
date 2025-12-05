import std/strutils
import std/algorithm
import std/sequtils
import std/strformat
import std/re
import std/tables
import std/sets
import std/math
import std/bitops

proc prepareInput(filename: string): seq[seq[char]] =
  var input: seq[seq[char]] = @[]
  for line in lines(filename):
    input.add(@line)
  return input

type xy = tuple[x: int, y: int]
func `+`(a: xy, b: xy): xy =
  (a.x + b.x, a.y + b.y)
func `in`[T](c: xy, map: seq[seq[T]]): bool =
  c.y in 0 ..< map.len and c.x in 0 ..< map[c.y].len
func `[]`[T](map: seq[seq[T]], pos: xy): lent T {.noSideEffect.} =
  map[pos.y][pos.x]
func `[]=`[T](map: var seq[seq[T]], pos: xy, v: T) =
  map[pos.y][pos.x] = v

func countAdjacent(map: seq[seq[char]], pos: xy): int =
  let dirs: seq[xy] =
    @[(-1, -1), (0, -1), (1, -1), (-1, 0), (1, 0), (-1, 1), (0, 1), (1, 1)]
  var count = 0
  for dir in dirs:
    let p: xy = (pos + dir)
    if p in map and map[p] == '@':
      #debugEcho &"{pos} + {dir} == @"
      count += 1
  return count

func part1(input: seq[seq[char]]): int =
  var sum = 0
  for (y, line) in input.pairs:
    for (x, pos) in line.pairs:
      if pos == '@':
        if input.countAdjacent((x, y)) < 4:
          #debugEcho (x, y)
          sum += 1
  return sum

func part2(input: seq[seq[char]]): int =
  var sum = 0
  var removed = true
  var map = input
  var map1 = input
  while removed:
    removed = false
    for (y, line) in map.pairs:
      for (x, pos) in line.pairs:
        if pos == '@':
          let p: xy = (x, y)
          if map.countAdjacent(p) < 4:
            map1[p] = '.'
            removed = true
            sum += 1
    map = map1
  return sum

when isMainModule:
  #echo prepareInput("Aoc04a.txt")
  echo $part1(prepareInput("Aoc04b.txt"))
  echo $part2(prepareInput("Aoc04b.txt"))
