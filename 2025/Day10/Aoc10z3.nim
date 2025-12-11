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
import z3nim

type inLine = tuple[bits: int, ops: seq[seq[int]], jolt: seq[int]]
type inType = seq[inLine]

proc prepareInput(filename: string): inType =
  var input: inType = @[]
  for line in lines(filename):
    var l:inLine = (0, @[], @[])
    let blocks = line.splitWhitespace
    for (i, b) in blocks[0][1..blocks[0].len - 2].pairs:
      if b == '#':
        l.bits.setBit(i)
    l.jolt = blocks[blocks.len - 1][1..blocks[blocks.len - 1].len - 2].split(',').mapIt(it.parseInt)
    for o in blocks[1..blocks.len - 2]:
      var op:seq[int] = @[]
      for bit in o[1..o.len - 2].split(',').mapIt(it.parseInt):
        op.add(bit)
      l.ops.add(op)
    input.add(l)
  return input

func part1(input: inType): int =
  return 0

proc part2(input: inType): int =
  var sum = 0
  for (linenum, l) in input.pairs:
    echo &"==================== Line {linenum} ===================="
    var varMap: Table[int, seq[int]] = initTable[int, seq[int]](0)
    for (i, op) in l.ops.pairs:
      for opVar in op:
        if not varMap.contains(opVar):
          varMap[opVar] = @[]
        varMap[opVar].add(i)
    z3:
      var vars: seq[Ast[IntSort]] = @[]
      for op in 0..<l.ops.len:
        let v = declConst(op, IntSort)
        assertOpt v >= 0
        vars.add(v)
      var minVar = declConst(99, IntSort)
      var min = vars[0]
      for v in vars[1..vars.high]:
         min = min + v
      #echo minVar == min
      #assertOpt minVar == min
      for (v, ops) in varMap.pairs:
        var eq: Ast[IntSort] = vars[ops[0]]
        for op in ops[1..ops.high]:
            eq = eq + vars[op]
        echo eq == l.jolt[v]
        assertOpt eq == l.jolt[v]
      let opt = minimize min
      echo checkOpt == sat
      let m = getModelOpt()
      sum += m.eval(min).toInt
  return sum

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