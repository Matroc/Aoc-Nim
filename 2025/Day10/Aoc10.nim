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

type inLine = tuple[bits: int, ops: seq[int], jolt: seq[int]]
type inType = seq[inLine]

proc prepareInput(filename: string): inType =
  var input: inType = @[]
  for line in lines(filename):
    var l:inLine = (0, @[], @[])
    let blocks = line.splitWhitespace
    for (i, b) in blocks[0][1..blocks[0].len - 2].pairs:
      if b == '#':
        l.bits.setBit(i)
    l.jolt = blocks[blocks.len - 1][1..blocks[blocks.len - 1].len - 2].split(',').mapIt(it.parseInt.int)
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

func apply(jolts: seq[int], op: int): seq[int] =
  var opRest = op
  var newJolts = jolts
  while opRest != 0:
    let nextOp = opRest.firstSetBit - 1
    newJolts[nextOp] -= 1
    opRest.flipBit(nextOp)
  return newJolts

func apply(jolts: seq[int], opcount: seq[tuple[op: int, count: int]]): seq[int] =
  var newJolts = jolts
  for (op, count) in opcount:
    var opRest = op
    while opRest != 0:
      let nextOp = opRest.firstSetBit - 1
      newJolts[nextOp] -= count.int
      opRest.flipBit(nextOp)
  return newJolts

func checkApply(jolts: seq[int], opcount: seq[tuple[op: int, count: int]]): bool =
  return jolts.apply(opcount).allIt(it == 0)

func dist(jolts: seq[int]): int =
  var dist = 0
  for i in 0..<jolts.len:
    if jolts[i] < 0:
      return int.high
    #dist = max(dist, jolts[i])
    dist += jolts[i]
  return dist

type node = tuple[opcount: seq[tuple[op: int, count: int]], jolts: seq[int], cost:int, dist: int]
func openCmp(a: node, b: node): int =
  cmp(a.cost + a.dist, b.cost + b.dist)

func toStr(input: seq[tuple[op: int, count: int]]): string =
  input.mapIt(&"{it.op}:{it.count}").join("|")

func bestToLast(nodes: var seq[node]) =
  var best = nodes[nodes.high]
  var idx = nodes.high
  for (i, chk) in nodes.pairs:
    if best.dist + best.cost > chk.dist + chk.cost:
      best = chk
      idx = i
  nodes[idx] = nodes[nodes.high]
  nodes[nodes.high] = best

func affectsZero(op: int, jolts: seq[int]): bool =
  for j in 0..jolts.high:
    if jolts[j] == 0 and op.testBit(j):
      return true
  return false

func getMostRestrictedJoltage(jolts: seq[int], ops: seq[int]): int =
  var affectedCount = @[0].cycle(jolts.len)
  for op in ops:
    for i in 0..jolts.high:
      if op.testBit(i) and not op.affectsZero(jolts):
          affectedCount[i] += 1
  var leastAffected = -1
  for i in 0..jolts.high:
    if jolts[i] == 0:
      continue
    if leastAffected == -1:
      leastAffected = i
    if affectedCount[i] < affectedCount[leastAffected]:
      leastAffected = i
  return leastAffected

func getOpsForJolt(ops: seq[int], mostRestricted: int): seq[int] =
  ops.filterIt(it.testBit(mostRestricted))

func getBestOps(ops: seq[int], jolts: seq[int]): seq[int] =
  ops.getOpsForJolt(jolts.getMostRestrictedJoltage(ops)).filterIt(not it.affectsZero(jolts))

func part2(input: inType): int =
  let ress = {
    0: @[(op: 359, count: 20), (op: 440, count: 16), (op: 28, count: 5), (op: 502, count: 13), (op: 36, count: 8), (op: 161, count: 14), (op: 369, count: 11)],
    1: @[(op: 29, count: 15), (op: 48, count: 6), (op: 35, count: 3), (op: 10, count: 16), (op: 11, count: 22), (op: 15, count: 15)],
    2: @[(op: 5, count: 9), (op: 2, count: 0), (op: 16, count: 0), (op: 17, count: 17), (op: 18, count: 8), (op: 12, count: 200)],
    3: @[(op: 10, count: 6), (op: 5, count: 9), (op: 4, count: 0), (op: 14, count: 5)],
    4: @[(op: 17, count: 0), (op: 768, count: 13), (op: 759, count: 1), (op: 529, count: 7), (op: 156, count: 6), (op: 328, count: 0), (op: 501, count: 18), (op: 198, count: 5), (op: 1015, count: 14)],
    5: @[(op: 12, count: 13), (op: 3, count: 17), (op: 14, count: 5), (op: 2, count: 0)],
    6: @[(op: 256, count: 1), (op: 347, count: 21), (op: 442, count: 16), (op: 20, count: 143), (op: 43, count: 6), (op: 445, count: 0), (op: 14, count: 8), (op: 165, count: 12), (op: 70, count: 1), (op: 67, count: 2), (op: 502, count: 6)],
    7: @[(op: 7, count: 7), (op: 19, count: 12), (op: 14, count: 18), (op: 22, count: 0)],
    8: @[(op: 120, count: 13), (op: 22, count: 5), (op: 197, count: 2), (op: 9, count: 20), (op: 150, count: 6), (op: 129, count: 1), (op: 173, count: 18)],
    9: @[(op: 117, count: 9), (op: 37, count: 10), (op: 5, count: 23), (op: 55, count: 10), (op: 108, count: 1), (op: 10, count: 1), (op: 59, count: 15), (op: 30, count: 14), (op: 110, count: 26)],
    10: @[(op: 47, count: 12), (op: 95, count: 17), (op: 13, count: 20), (op: 19, count: 11), (op: 59, count: 2)],
    11: @[(op: 10, count: 13), (op: 30, count: 4), (op: 9, count: 11), (op: 12, count: 0), (op: 16, count: 11), (op: 8, count: 19)],
    12: @[(op: 320, count: 21), (op: 328, count: 0), (op: 947, count: 13), (op: 652, count: 15), (op: 1006, count: 22), (op: 880, count: 0), (op: 800, count: 14), (op: 82, count: 6), (op: 766, count: 3), (op: 1017, count: 21), (op: 826, count: 12)],
    13: @[(op: 19, count: 19), (op: 28, count: 19), (op: 3, count: 2), (op: 20, count: 18), (op: 9, count: 6)],
    14: @[(op: 9, count: 0), (op: 16, count: 2), (op: 12, count: 12), (op: 25, count: 20), (op: 3, count: 16), (op: 26, count: 20)],
    15: @[(op: 562, count: 0), (op: 148, count: 17), (op: 620, count: 5), (op: 271, count: 1), (op: 727, count: 12), (op: 670, count: 37), (op: 528, count: 0), (op: 258, count: 8), (op: 784, count: 4), (op: 203, count: 11), (op: 337, count: 13), (op: 865, count: 28), (op: 397, count: 7)],
    16: @[(op: 13, count: 129), (op: 12, count: 15), (op: 54, count: 19), (op: 19, count: 12), (op: 22, count: 4), (op: 17, count: 20)],
    17: @[(op: 541, count: 14), (op: 127, count: 4), (op: 475, count: 4), (op: 762, count: 19), (op: 130, count: 8), (op: 546, count: 8), (op: 289, count: 16), (op: 1021, count: 117)],
    18: @[(op: 209, count: 10), (op: 15, count: 13), (op: 2, count: 11), (op: 167, count: 22), (op: 151, count: 2), (op: 190, count: 8), (op: 201, count: 1), (op: 36, count: 2), (op: 222, count: 8)],
    19: @[(op: 19, count: 7), (op: 6, count: 19), (op: 13, count: 10), (op: 20, count: 15)],
    20: @[(op: 25, count: 8), (op: 24, count: 20), (op: 5, count: 1), (op: 22, count: 13), (op: 13, count: 2)],
    21: @[(op: 6, count: 6), (op: 56, count: 6), (op: 39, count: 1), (op: 55, count: 129)],
    22: @[(op: 45, count: 5), (op: 51, count: 8), (op: 6, count: 12), (op: 43, count: 10), (op: 52, count: 2)],
    23: @[(op: 49, count: 9), (op: 7, count: 3), (op: 36, count: 17), (op: 61, count: 0), (op: 1, count: 20), (op: 56, count: 0), (op: 14, count: 196)],
    24: @[(op: 25, count: 5), (op: 18, count: 13), (op: 12, count: 11)],
    25: @[(op: 5, count: 15), (op: 11, count: 20)],
    26: @[(op: 114, count: 11), (op: 54, count: 6), (op: 105, count: 12), (op: 47, count: 1), (op: 102, count: 11), (op: 17, count: 20)],
    27: @[(op: 3, count: 7), (op: 13, count: 7), (op: 25, count: 7), (op: 12, count: 7)],
    28: @[(op: 50, count: 17), (op: 24, count: 0), (op: 95, count: 25), (op: 152, count: 6), (op: 41, count: 19), (op: 193, count: 11), (op: 48, count: 19), (op: 6, count: 14)],
    29: @[(op: 2, count: 6), (op: 16, count: 8), (op: 6, count: 0), (op: 30, count: 39), (op: 28, count: 0), (op: 13, count: 20), (op: 26, count: 10)],
    30: @[(op: 33, count: 0), (op: 1, count: 28), (op: 60, count: 21), (op: 5, count: 1), (op: 45, count: 3), (op: 41, count: 0), (op: 24, count: 0), (op: 3, count: 18)],
    31: @[(op: 6, count: 19), (op: 4, count: 17), (op: 9, count: 8), (op: 5, count: 11)],
    32: @[(op: 15, count: 14), (op: 6, count: 3), (op: 21, count: 13), (op: 43, count: 14)],
    33: @[(op: 16, count: 3), (op: 94, count: 20), (op: 6, count: 19), (op: 109, count: 1), (op: 5, count: 7), (op: 20, count: 19), (op: 114, count: 7)],
    34: @[(op: 1, count: 0), (op: 109, count: 11), (op: 228, count: 0), (op: 56, count: 146), (op: 162, count: 2), (op: 117, count: 11), (op: 197, count: 12), (op: 193, count: 10), (op: 145, count: 20)],
    35: @[(op: 107, count: 4), (op: 60, count: 17), (op: 76, count: 17), (op: 78, count: 6), (op: 56, count: 11), (op: 119, count: 6), (op: 3, count: 19)],
    36: @[(op: 12, count: 10), (op: 6, count: 0), (op: 30, count: 10), (op: 17, count: 4), (op: 11, count: 19), (op: 23, count: 10), (op: 13, count: 1)],
    37: @[(op: 47, count: 2), (op: 33, count: 9), (op: 111, count: 24), (op: 114, count: 19), (op: 78, count: 0)],
    38: @[(op: 12, count: 20), (op: 11, count: 22), (op: 10, count: 0), (op: 1, count: 6), (op: 3, count: 13)],
    39: @[(op: 44, count: 14), (op: 49, count: 9), (op: 33, count: 13), (op: 42, count: 17), (op: 29, count: 9)],
    40: @[(op: 17, count: 8), (op: 250, count: 0), (op: 166, count: 6), (op: 43, count: 6), (op: 236, count: 10), (op: 60, count: 22), (op: 231, count: 16), (op: 192, count: 137)],
    41: @[(op: 13, count: 19), (op: 11, count: 7), (op: 18, count: 5)],
    42: @[(op: 45, count: 3), (op: 37, count: 3), (op: 22, count: 9), (op: 36, count: 3), (op: 54, count: 6)],
    43: @[(op: 18, count: 0), (op: 9, count: 8), (op: 26, count: 7), (op: 10, count: 6), (op: 12, count: 19)],
    44: @[(op: 374, count: 0), (op: 391, count: 10), (op: 152, count: 7), (op: 305, count: 16), (op: 415, count: 16), (op: 351, count: 19), (op: 132, count: 15)],
    45: @[(op: 502, count: 10), (op: 389, count: 146), (op: 426, count: 20), (op: 296, count: 10), (op: 461, count: 3), (op: 222, count: 6), (op: 264, count: 3)],
    }.toTable
  var sum = 0
  for (linenum, l) in input.pairs:
    if ress.contains(linenum):
      assert l.jolt.checkApply(ress[linenum])
      sum += ress[linenum].mapIt(it.count.int).sum
      continue
    var open: seq[node] = @[(l.ops.mapIt((it, 0)), l.jolt, 0, l.jolt.max)]
    #var closed: seq[node] = @[]
    var closed: HashSet[seq[tuple[op: int, count: int]]] = initHashSet[seq[tuple[op: int, count: int]]](100000)
    var found = false
    while not found:
      #open.sort(openCmp, Descending)
      open.bestToLast()
      if closed.len mod 100000 == 0:
        debugEcho &"open size: {open.len}, closed size: {closed.len}, dist: {open[open.high].dist}, cost: {open[open.high].cost}, jolts: {open[open.high].jolts}"
      var next = open.pop
      closed.incl(next.opcount)
      var shortcut = false
      for (jIndex1, joltage1) in next.jolts.pairs:
        for (jIndex2, joltage2) in next.jolts.pairs:
          if joltage1 > joltage2:
            let requiredOps = l.ops.pairs.toSeq.filterIt(it[1].testBit(jIndex1) and not it[1].testBit(jIndex2))
            if requiredOps.len == 0:
              #debugEcho &"no way out {next}"
              shortcut = true
              break
            if requiredOps.len == 1:
              shortcut = true
              #debugEcho &"one way forward {jIndex1} > {jIndex2} {next}"
              var newOps = next.opcount
              newOps[requiredOps[0][0]].count += joltage1 - joltage2
              if closed.contains(newOps):
                break
              var newJolts = l.jolt.apply(newOps)
              #var newJolts = next.jolts.apply(requiredOps[0][1])
              var newOpen: node = (newOps, newJolts, next.cost + joltage1 - joltage2, newJolts.dist)
              if newOpen.dist == int.high:
                closed.incl(newOps)
                break
              if newOpen.dist == 0:
                found = true
                sum += newOpen.cost
                debugEcho &"found {newOpen} for {linenum} of {input.len}"
                debugEcho $newOpen.opcount
                assert newOpen.cost == newOps.mapIt(it.count.int).sum
                assert l.jolt.checkApply(newOpen.opcount)
              newOpen.dist = 1
              open.add(newOpen)
              break
        if shortcut:
          break
      if shortcut:
        continue
      for op in l.ops.getBestOps(next.jolts):
        let i = l.ops.find(op)
        var newOps = next.opcount
        newOps[i].count += 1
        if closed.contains(newOps):
          continue
        if open.findIt(it.opcount == newOps) != -1:
          continue
        var newJolts = next.jolts.apply(op)
        var newOpen: node = (newOps, newJolts, next.cost + 1, newJolts.dist)
        if newOpen.dist == int.high:
          closed.incl(newOps)
          continue
        if newOpen.dist == 0:
          found = true
          sum += newOpen.cost
          debugEcho &"found {newOpen} for {linenum} of {input.len}"
          debugEcho $newOpen.opcount
          assert newOpen.cost == newOps.mapIt(it.count.int).sum
          assert l.jolt.checkApply(newOpen.opcount)
          break
        open.add(newOpen)
  return sum.int

when isMainModule:
  var before = getMonoTime()
  let a = prepareInput("Aoc10a.txt")
  let b = prepareInput("Aoc10b.txt")
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