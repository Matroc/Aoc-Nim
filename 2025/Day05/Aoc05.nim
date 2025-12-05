import std/strutils
import std/algorithm
import std/sequtils
import std/strformat
import std/re
import std/tables
import std/sets
import std/math
import std/bitops


proc prepareInput(
    filename: string, filename2: string
): tuple[fresh: seq[HSlice[int, int]], ids: seq[int]] =
  var fresh: seq[HSlice[int, int]] = @[]
  for line in lines(filename):
    let vals = line.split('-')
    fresh.add(vals[0].parseInt .. vals[1].parseInt)
  var ids: seq[int] = @[]
  for line in lines(filename2):
    ids.add(line.parseInt)
  return (fresh, ids)

func part1(input: tuple[fresh: seq[HSlice[int, int]], ids: seq[int]]): int =
  var sum = 0
  for id in input.ids:
    var fresh = false
    for f in input.fresh:
      if id in f:
        fresh = true
        sum += 1
        break
    if fresh:
      continue
  return sum

func findOverlap(db: seq[HSlice[int, int]], chk: HSlice[int, int]): int =
  for (i, v) in db.pairs:
    if v.a in chk or v.b in chk or chk.a in v or chk.b in v:
      return i
  return -1

func part2(input: tuple[fresh: seq[HSlice[int, int]], ids: seq[int]]): int =
  var f2: seq[HSlice[int, int]] = @[]
  for r in input.fresh:
    var rMod = r
    var match = f2.findOverlap(rMod)
    while match != -1:
      rMod = min(rMod.a, f2[match].a)..max(rMod.b, f2[match].b)
      f2.delete(match)
      match = f2.findOverlap(rMod)
    f2.add(rMod)
  var count = 0
  for r in f2:
    count += r.len
  return count

when isMainModule:
  echo prepareInput("Aoc05a.txt", "Aoc05a2.txt")
  echo $part1(prepareInput("Aoc05b.txt", "Aoc05b2.txt"))
  echo $part2(prepareInput("Aoc05b.txt", "Aoc05b2.txt"))
