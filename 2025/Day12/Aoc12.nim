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
import std/bitops
import std/sets
import std/deques
import std/packedsets

type inLine = tuple[x: int, y: int, gifts: seq[int]]
type gift = seq[seq[bool]]
type inType = tuple[gifts: seq[gift], inLines: seq[inLine]]

proc prepareInput(filename: string): inType =
  var gifts: seq[gift] = @[]
  var lines: seq[inLine]
  var gift = false
  for line in lines(filename):
    if line.len == 0:
      if gift:
        gift = false
    elif gift:
      gifts[gifts.high].add(line.mapIt(it == '#'))
    elif line[line.high] == ':':
      gift = true
      gifts.add(@[])
    else:
      let cols = line.split(" ")
      assert cols.len == gifts.len + 1
      let size = cols[0][0..<cols[0].high].split('x').mapIt(it.parseInt)
      let giftCounts = cols[1..cols.high].mapIt(it.parseInt)
      lines.add((size[0], size[1], giftCounts))
  return (gifts, lines)

func rotate(g: gift): gift =
  result = g
  for (y, line) in g.pairs:
    for (x, v) in line.pairs:
      result[x][2 - y] = v

func flip(g: gift): gift =
  result = g
  for (y, line) in g.pairs:
    for (x, v) in line.pairs:
      result[y][2 - x] = v

func getVariants(g: gift): seq[gift] =
  result = @[]
  var changedGift = g
  for rot in 0..3:
    if changedGift notin result:
      result.add(changedGift)
    let changedGiftMirror = changedGift.flip
    if changedGiftMirror notin result:
      result.add(changedGiftMirror)
    changedGift = changedGift.rotate

func makeBitMask(g: gift, cols: int, offset: int): PackedSet[int] =
  result = initPackedSet[int]()
  for (y, line) in g.pairs:
    for (x, v) in line.pairs:
      if v:
        result.incl((y + (offset div (cols - 2))) * cols + x + (offset mod (cols - 2)))

type giftIdx = tuple[gift: int, variant: int, offset: int]

func part1(input: inType): int =
  var sum = 0
  for line in input.inLines:
    if line.x * line.y >= (line.gifts.sum * 9):
      inc sum
  return sum

when isMainModule:
  var before = getMonoTime()
  let a = prepareInput("Aoc12a.txt")
  let b = prepareInput("Aoc12b.txt")
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