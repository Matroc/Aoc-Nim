import std/strutils
import std/math


proc prepareInput(filename: string): tuple[fresh: seq[Slice[int]], ids: seq[int]] =
  var fresh: seq[Slice[int]] = @[]
  let input = readFile(filename).split("\n\n")
  for line in input[0].splitLines:
    let vals = line.split('-')
    fresh.add(vals[0].parseInt .. vals[1].parseInt)
  var ids: seq[int] = @[]
  for line in input[1].splitLines:
    ids.add(line.parseInt)
  return (fresh, ids)

func part1(input: tuple[fresh: seq[Slice[int]], ids: seq[int]]): int =
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

func findOverlap(ranges: seq[Slice[int]], search: Slice[int]): int =
  for (i, v) in ranges.pairs:
    if v.a in search or v.b in search or search.a in v or search.b in v:
      return i
  return -1

func mergeRanges(ranges: seq[Slice[int]]): seq[Slice[int]] = 
  result = @[]
  for r in ranges:
    var rMerged = r
    var match = result.findOverlap(rMerged)
    while match != -1:
      rMerged = min(rMerged.a, result[match].a)..max(rMerged.b, result[match].b)
      result.delete(match)
      match = result.findOverlap(rMerged)
    result.add(rMerged)

func part2(input: tuple[fresh: seq[Slice[int]], ids: seq[int]]): int =
  let merged = input.fresh.mergeRanges
  var count = 0
  for r in merged:
    count += r.len
  return count

when isMainModule:
  echo prepareInput("Aoc05a.txt")
  echo $part1(prepareInput("Aoc05b.txt"))
  echo $part2(prepareInput("Aoc05b.txt"))
