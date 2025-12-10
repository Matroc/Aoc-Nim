import std/sequtils
import std/strutils
import std/strformat
import std/tables
import std/math
import std/algorithm
import std/sugar
import std/typeinfo
import std/monotimes
import std/times

type xyz = tuple[x: int, y: int, z: int]

type xy = tuple[x: int, y: int]
func `+`(a: xy, b: xy): xy =
  (a.x + b.x, a.y + b.y)
func `-`(a: xy, b: xy): xy =
  (a.x - b.x, a.y - b.y)
func area(a: xy, b: xy): int =
  let area = b - a
  return (abs(area.x) + 1) * (abs(area.y) + 1)
func `in`[T](c: xy, map: seq[seq[T]]): bool =
  c.y in 0 ..< map.len and c.x in 0 ..< map[c.y].len
func `[]`[T](map: seq[seq[T]], pos: xy): lent T {.noSideEffect.} =
  map[pos.y][pos.x]
func `[]=`[T](map: var seq[seq[T]], pos: xy, v: T) =
  map[pos.y][pos.x] = v

type inType = seq[xy]

proc prepareInput(filename: string): inType =
  var input: inType = @[]
  for line in lines(filename):
    let vals = line.split(',')
    input.add((vals[0].parseInt, vals[1].parseInt))
  return input

func part1(input: inType): int =
  let combinations = @[(0..<input.len).toSeq, (0..<input.len).toSeq].product
  var areas: seq[xyz] = @[]
  for idx in combinations:
    if(idx[0] < idx[1]):
      areas.add((idx[0], idx[1], area(input[idx[0]], input[idx[1]])))
  areas.sort((a, b) => cmp(a.z, b.z), Descending)
  return areas[0].z

func intersect(a: Slice[int], b: Slice[int]): bool =
  a.a < b.b and a.b > b.a

func check(a:xy, b:xy, input: inType): bool =
  let xRange = min(a.x, b.x)+1..<max(a.x, b.x)
  let yRange = min(a.y, b.y)+1..<max(a.y, b.y)
  var prev = input[input.len - 1]
  for point in input:
    if prev.x == point.x:
      if point.x in xRange:
        if yRange.intersect(min(prev.y, point.y)..max(prev.y, point.y)):
          return false
    else:
      if point.y in yRange:
        if xRange.intersect(min(prev.x, point.x)..max(prev.x, point.x)):
          return false
    prev = point
  return true

func part2(input: inType): int =
  let combinations = @[(0..<input.len).toSeq, (0..<input.len).toSeq].product
  var areas: seq[xyz] = @[]
  for idx in combinations:
    if(idx[0] < idx[1]):
      areas.add((idx[0], idx[1], area(input[idx[0]], input[idx[1]])))
  areas.sort((a, b) => cmp(a.z, b.z), Descending)
  for area in areas:
    if check(input[area.x], input[area.y], input):
      return area.z

when isMainModule:
  var before = getMonoTime()
  let a = prepareInput("Aoc09a.txt")
  let b = prepareInput("Aoc09b.txt")
  var time = getMonoTime() - before
  echo &"Parsing inputs in {time.inSeconds}.{(time.inNanoseconds mod 1000000000):09d}s: {a}"
  var res: string
  when declared(part1): 
    before = getMonoTime()
    when declared(b): 
      res = $part1(b)
    else:
      res = $part1(a)
    time = getMonoTime() - before
    echo &"Part 1 res: {res} calculated in {time.inSeconds}.{(time.inNanoseconds mod 1000000000):09d}s"
  when declared(part2):
    before = getMonoTime()
    when declared(b): 
      res = $part2(b)
    else:
      res = $part2(a)
    time = getMonoTime() - before
    echo &"Part 2 res: {res} calculated in {time.inSeconds}.{(time.inNanoseconds mod 1000000000):09d}s"