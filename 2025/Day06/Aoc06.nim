import std/strutils
import std/sequtils
import std/math

type inputType = tuple[numbers: seq[seq[int]], ops: seq[string]]

proc prepareInput(filename: string): inputType =
  var input: seq[seq[int]] = @[]
  var ops: seq[string] = @[]
  for line in lines(filename):
    if line.contains('+'):
      ops = line.splitWhitespace
    else:
      input.add(line.splitWhitespace.mapIt(it.parseInt))
  return (numbers: input, ops: ops)

func part1(input: inputType): int =
  var sum = 0
  for (x, op) in input.ops.pairs:
    var col = input.numbers[0][x]
    for row in input.numbers[1..<input.numbers.len].mapIt(it[x]):
      if op == "+":
        col += row
      elif op == "*":
        col *= row
    sum += col
  return sum

proc prepareInput2(filename: string): inputType =
  let lines: seq[string] = readFile(filename).splitLines
  var input: seq[seq[int]] = @[]
  var ops: seq[string] = @[]
  var opsLine = lines[lines.len - 1]
  var col = -1
  var charCol2 = 0
  for charcol in 0..<lines[0].len:
    let op = opsline[charcol]
    if op != ' ':
      ops.add($op)
      col += 1
      charCol2 = 0
    for (linenum, line) in lines[0..<lines.len-1].pairs:
      while input.len <= col:
          input.add(@[])
      if line[charcol] != ' ':
        while input[col].len <= charCol2:
          input[col].add(0)
        input[col][charCol2] = input[col][charCol2] * 10 + ($line[charcol]).parseInt
    charCol2 += 1
  return (numbers: input, ops: ops)

func part2(input: inputType): int =
  var sum = 0
  for (x, op) in input.ops.pairs:
    var col = input.numbers[x][0]
    for row in input.numbers[x][1..<input.numbers[x].len]:
      if op == "+":
        col += row
      elif op == "*":
        col *= row
    sum += col
  return sum

when isMainModule:
  echo prepareInput("Aoc06a.txt")
  echo $part1(prepareInput("Aoc06b.txt"))
  echo prepareInput2("Aoc06a.txt")
  echo $part2(prepareInput2("Aoc06b.txt"))
