import std/sequtils
import std/strformat
import std/strutils
import std/tables
import std/math
import std/re

type xy = tuple[x: int, y: int]
func `+`(a: xy, b: xy): xy =
  (a.x + b.x, a.y + b.y)
func `in`[T](c: xy, map: seq[seq[T]]): bool =
  c.y in 0 ..< map.len and c.x in 0 ..< map[c.y].len
func `[]`[T](map: seq[seq[T]], pos: xy): lent T {.noSideEffect.} =
  map[pos.y][pos.x]
func `[]=`[T](map: var seq[seq[T]], pos: xy, v: T) =
  map[pos.y][pos.x] = v

type inType = seq[seq[char]]

proc prepareInput(filename: string): inType =
  var input: seq[seq[char]] = @[]
  for line in lines(filename):
    if line.find(re"[S\^]") == -1:
      continue
    input.add(@line)
  return input

func part1(input: inType): int =
  let splitDirs = @[(-1, 0), (1,0)]
  let beamCheck = (0, -1)
  var map = input
  var sum = 0
  for (y, line) in input[0..<input.len].pairs:
    if y == 0:
      continue
    for (x, col) in line.pairs:
      let pos = (x, y)
      if map[pos + beamCheck] in @['S', '|']:
        if col == '^':
          sum += 1
          for split in splitDirs:
            map[pos + split] = '|'
        else:
          map[pos] = '|'
  return sum

func debugPrintMap(map: seq[seq[int]]) =
  for line in map:
    debugEcho line.mapIt(&"{it:>2}").join("|") & &" = {line.sum}"

func part2(input: inType): int =
  let splitDirs = @[(-1, 0), (1,0)]
  let beamCheck = (0, -1)
  let mapping = {'S': 1, '.': 0, '^': 0}.toTable
  var map = input.mapIt(it.mapIt(mapping[it]))
  for (y, line) in input[0..<input.len].pairs:
    if y == 0:
      continue
    for (x, col) in line.pairs:
      let pos = (x, y)
      let beamVal = map[pos + beamCheck]
      if beamVal > 0:
        if col == '^':
          for split in splitDirs:
            let newDir = pos + split
            map[newDir] = map[newDir] + beamVal
        else:
          map[pos] = map[pos] + beamVal 
  #map.debugPrintMap
  return map[map.len - 1].sum

when isMainModule:
  echo prepareInput("Aoc07a.txt")
  echo $part1(prepareInput("Aoc07b.txt"))
  echo $part2(prepareInput("Aoc07b.txt"))
