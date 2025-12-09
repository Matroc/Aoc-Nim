import std/sequtils
import std/strutils
import std/strformat
import std/tables
import std/math
import std/algorithm
import std/sugar

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

func set(cache: var seq[seq[byte]], pos: xy, val: byte) =
  cache[pos.y][pos.x] = val

func drawOutline(cache: var seq[seq[byte]], outline: inType, val: byte) =
  var prev = outline[outline.len - 1]
  for point in outline:
    if prev.x == point.x:
      for y in min(prev.y, point.y)..max(prev.y, point.y):
        cache.set((prev.x, y), val)
    else:
      for x in min(prev.x, point.x)..max(prev.x, point.x):
        cache.set((x, prev.y), val)
    prev = point

func fill(cache: var seq[seq[byte]], start: xy, val: byte) =
  let dirs = @[(-1, 0), (1, 0), (0, -1), (0, 1)]
  var queue = @[start]
  while queue.len > 0:
    let v = queue.pop
    if v.y in 0..<cache.len:
      if v.x in 0..<cache[v.y].len:
        if cache[v.y][v.x] == 255.byte:
          cache[v.y][v.x] = val
          for d in dirs:
            queue.add(v + d)

func get(cache: var seq[seq[byte]], a:xy): byte =
  return cache[a.y][a.x]

func check(cache: var seq[seq[byte]], a:xy, b:xy): bool =
  let outline = @[a, (a.x, b.y), b, (b.x, a.y)]
  var prev = outline[outline.len - 1]
  for point in outline:
    if prev.x == point.x:
      for y in min(prev.y, point.y)..max(prev.y, point.y):
        if cache.get((prev.x, y)) == 0.byte:
          return false
    else:
      for x in min(prev.x, point.x)..max(prev.x, point.x):
        if cache.get((x, prev.y)) == 0.byte:
          return false
    prev = point
  return true

func init(cache: var seq[seq[byte]], max: xy) =
  for x in 0..max.y + 1:
    cache.add(@[255.byte].cycle(max.x + 2))

func debugOut(cache: seq[seq[byte]]) =
  let mapping = {255.byte: " ", 0.byte: "0", 1.byte: "X"}.toTable
  for line in cache:
    debugEcho line.mapIt(mapping[it]).join

func part2(input: inType): int =
  var size: xy = (0, 0)
  for inp in input:
    size = (max(inp.x, size.x), max(inp.y, size.y))
  debugEcho &"size {size}"
  var cache: seq[seq[byte]] = @[]
  cache.init(size)
  debugEcho "init done"
  cache.drawOutline(input, 1)
  debugEcho "outline done"
  cache.fill((0, 0), 0)
  debugEcho "fill done"
  #cache.debugOut
  let combinations = @[(0..<input.len).toSeq, (0..<input.len).toSeq].product
  var areas: seq[xyz] = @[]
  for idx in combinations:
    if(idx[0] < idx[1]):
      areas.add((idx[0], idx[1], area(input[idx[0]], input[idx[1]])))
  areas.sort((a, b) => cmp(a.z, b.z), Descending)
  for area in areas:
    #debugEcho &"check {input[area.x]} {input[area.y]} of size {area.z}"
    if cache.check(input[area.x], input[area.y]):
      return area.z

when isMainModule:
  echo prepareInput("Aoc09a.txt")
  echo $part1(prepareInput("Aoc09a.txt"))
  echo $part2(prepareInput("Aoc09b.txt"))
