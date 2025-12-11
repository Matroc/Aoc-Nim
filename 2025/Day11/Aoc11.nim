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

type inLine = seq[string]
type inType = seq[inLine]

proc prepareInput(filename: string): inType =
  var input: inType = @[]
  for line in lines(filename):
    input.add(line.split(" "))
  return input

func part1(input: inType): int =
  var sum = 0
  var net = initTable[string, seq[string]]()
  for line in input:
    net[line[0][0..2]] = line[1..line.high]
  var next = net["you"]
  while next.len > 0:
    var step = next.pop
    if step == "out":
      sum += 1
      continue
    next.add(net[step])
  return sum

func countWays(map: Table[string, tuple[outgoing: seq[string], incomingCount: int]], start: string, destination:string): int =
  var queue = @["svr"].toDeque
  var topologicalOrder: seq[string] = @[]
  var mapCopy = map
  while queue.len > 0:
    var next = queue.popFirst
    topologicalOrder.add(next)
    for outgoing in mapCopy[next].outgoing:
      mapCopy[outgoing].incomingCount -= 1
      if mapCopy[outgoing].incomingCount == 0:
        queue.addLast(outgoing)
  var waysTo = initTable[string, int]()
  waysTo[start] = 1
  for node in topologicalOrder:
    if node notin waysTo:
      waysTo[node] = 0
    for outgoing in map[node].outgoing:
      if outgoing in waysTo:
        waysTo[outgoing] += waysTo[node]
      else:
        waysTo[outgoing] = waysTo[node]
  return waysTo[destination]


func part2(input: inType): int =
  var net = initTable[string, tuple[outgoing: seq[string], incomingCount: int]]()
  for line in input:
    net[line[0][0..2]] = (line[1..line.high], 0)
  for line in input:
    for outgoing in line[1..line.high]:
      if outgoing notin net:
        net[outgoing] = (@[], 0)
      net[outgoing].incomingCount += 1
  var svrToDac = net.countWays("svr", "dac")
  var dacToFft = net.countWays("dac", "fft")
  var fftToOut = net.countWays("fft", "out")

  var svrToFft = net.countWays("svr", "fft")
  var fftToDac = net.countWays("fft", "dac")
  var dacToOut = net.countWays("dac", "out")
  
  return svrToDac * dacToFft * fftToOut + svrToFft * fftToDac * dacToOut

when isMainModule:
  var before = getMonoTime()
  let a = prepareInput("Aoc11a.txt")
  let a2 = prepareInput("Aoc11a2.txt")
  let b = prepareInput("Aoc11b.txt")
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
      res = $part2(a2)
    time = getMonoTime() - before
    echo &"Part 2 res: {res} calculated in {time.inSeconds}.{(time.inNanoseconds mod 1000000000):09d}s"