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

type inLine = tuple[bits: int, ops: seq[int], jolt: seq[uint]]
type inType = seq[inLine]

proc prepareInput(filename: string): inType =
  var input: inType = @[]
  for line in lines(filename):
    var l:inLine = (0, @[], @[])
    let blocks = line.splitWhitespace
    for (i, b) in blocks[0][1..blocks[0].len - 2].pairs:
      if b == '#':
        l.bits.setBit(i)
    l.jolt = blocks[blocks.len - 1][1..blocks[blocks.len - 1].len - 2].split(',').mapIt(it.parseInt.uint)
    for o in blocks[1..blocks.len - 2]:
      var op = 0
      for bit in o[1..o.len - 2].split(',').mapIt(it.parseInt):
        op.setBit(bit)
      l.ops.add(op)
    input.add(l)
  return input

func bitCountCmp(a: seq[bool], b: seq[bool]): int =
  cmp(a.count(true), b.count(true))

func part1(input: inType): int =
  var sum = 0
  for l in input:
    var possibilities = @[@[false, true]].cycle(l.ops.len).product
    possibilities.sort(bitCountCmp, Ascending)
    for pos in possibilities:
      var posRes = 0
      for (i, flip) in pos.pairs:
        if flip:
          posRes.flipMask(l.ops[i])
      if posRes == l.bits:
        sum += pos.count(true)
        break
  return sum

func apply(jolts: seq[uint], op: int): seq[uint] =
  var opRest = op
  var newJolts = jolts
  while opRest != 0:
    let nextOp = opRest.firstSetBit - 1
    newJolts[nextOp] += 1
    opRest.flipBit(nextOp)
  return newJolts

func getJolts(ops: seq[int], joltLen: int): seq[uint] =
  result = @[0u].cycle(joltLen)
  for op in ops:
    result = result.apply(op)

func dist(jolts: seq[uint], target: seq[uint]): uint =
  var dist = 0u64
  for i in 0..<jolts.len:
    if jolts[i] > target[i]:
      return uint.high
    dist = max(dist, target[i] - jolts[i])
    #dist += (target[i] - jolts[i]) * (target[i] - jolts[i])
    #dist = dist.rotateLeftBits(9)
    #dist += (target[i] - jolts[i]).uint
  return dist

type node = tuple[opcount: seq[tuple[op: int, count: int]], jolts: seq[uint], cost:uint, dist: uint]
func openCmp(a: node, b: node): int =
  cmp(a.cost + a.dist, b.cost + b.dist)

func toStr(input: seq[tuple[op: int, count: int]]): string =
  input.mapIt(&"{it.op}:{it.count}").join("|")

func part2(input: inType): int =
  var sum = 0u
  var mincost = uint.high
  for (linenum, l) in input.pairs:
    var open: seq[node] = @[(l.ops.mapIt((it, 0)), @[0u].cycle(l.jolt.len), 0u, l.jolt.max)]
    #var closed: seq[node] = @[]
    var closed: HashSet[seq[tuple[op: int, count: int]]] = initHashSet[seq[tuple[op: int, count: int]]](100000)
    var found = false
    while not found:
      if closed.len mod 10000 == 0:
        debugEcho &"open size: {open.len}, closed size: {closed.len}, dist: {open[open.len - 1].dist}, cost: {open[open.len - 1].cost}, mincost: {mincost}"
      open.sort(openCmp, Descending)
      var next = open.pop
      mincost = min(mincost, next.dist + next.cost)
      closed.incl(next.opcount)
      var shortcut = false
      for (jIndex1, joltage1) in next.jolts.pairs:
        for (jIndex2, joltage2) in next.jolts.pairs:
          if (l.jolt[jIndex1] - joltage1) > (l.jolt[jIndex2] - joltage2):
            let requiredOps = l.ops.pairs.toSeq.filterIt(it[1].testBit(jIndex1) and not it[1].testBit(jIndex2))
            if requiredOps.len == 0:
              #debugEcho &"no way out {next}"
              shortcut = true
              break
            if requiredOps.len == 1:
              #debugEcho &"one way forward {jIndex1} > {jIndex2} {next}"
              var newOps = next.opcount
              newOps[requiredOps[0][0]].count += 1
              var newJolts = next.jolts.apply(requiredOps[0][1])
              var newOpen: node = (newOps, newJolts, next.cost + 1, newJolts.dist(l.jolt))
              shortcut = true
              if newOpen.dist == uint.high:
                break
              if newOpen.dist == 0:
                found = true
                sum += newOpen.cost
                debugEcho &"found {newOpen} for {linenum} of {input.len}"
              newOpen.dist = 1
              open.add(newOpen)
              break
        if shortcut:
          break
      if shortcut:
        continue
      for (i, op) in l.ops.pairs:
        var newOps = next.opcount
        newOps[i].count += 1
        if closed.contains(newOps):
          continue
        if open.findIt(it.opcount == newOps) != -1:
          continue
        var newJolts = next.jolts.apply(op)
        var newOpen: node = (newOps, newJolts, next.cost + 1, newJolts.dist(l.jolt))
        if newOpen.dist == uint.high:
          continue
        if newOpen.dist == 0:
          found = true
          sum += newOpen.cost
          debugEcho &"found {newOpen} for {linenum} of {input.len}"
          break
        open.add(newOpen)
  return sum.int

when isMainModule:
  var before = getMonoTime()
  let a = prepareInput("Aoc10a.txt")
  #let b = prepareInput("Aoc10b.txt")
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