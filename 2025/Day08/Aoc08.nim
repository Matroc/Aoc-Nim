import std/sequtils
import std/strutils
import std/tables
import std/math
import std/algorithm
import std/sugar

type xyz = tuple[x: int, y: int, z: int]
func lenSq(a: xyz): int =
  (a.x * a.x + a.y * a.y + a.z * a.z)
func `-`(a: xyz, b: xyz): xyz =
  (a.x - b.x, a.y - b.y, a.z - b.z)
func distSq(a: xyz, b:xyz): int =
  (b - a).lenSq

type inType = seq[xyz]

proc prepareInput(filename: string): inType =
  var input: inType = @[]
  for line in lines(filename):
    let vals = line.split(',')
    input.add((vals[0].parseInt, vals[1].parseInt, vals[2].parseInt))
  return input

func replace[T](s: var seq[T], occurences: T, with: T) =
  for i in 0..<s.len:
    if s[i] == occurences:
      s[i] = with

func part1(input: inType): int =
  var networks: seq[int] = (0..<input.len).toSeq
  var netSizes: seq[int] = @[1].cycle(input.len)
  let combinations = @[(0..<input.len).toSeq, (0..<input.len).toSeq].product
  var dists: seq[xyz] = @[]
  for idx in combinations:
    if(idx[0] < idx[1]):
      dists.add((idx[0], idx[1], distSq(input[idx[0]], input[idx[1]])))
  dists.sort((a, b) => cmp(a.z, b.z))
  for comb in dists[0..<1000]:
    let netA = networks[comb.x]
    let netB = networks[comb.y]
    if netA == netB:
      continue
    netSizes[netA] = netSizes[netA] + netSizes[netB]
    netSizes[netB] = 0
    networks.replace(netB, netA)
  netSizes.sort(Descending)
  return netSizes[0] * netSizes[1] * netSizes[2]

func part2(input: inType): int =
  var networks: seq[int] = (0..<input.len).toSeq
  var netSizes: seq[int] = @[1].cycle(input.len)
  let combinations = @[(0..<input.len).toSeq, (0..<input.len).toSeq].product
  var dists: seq[xyz] = @[]
  for idx in combinations:
    if(idx[0] < idx[1]):
      dists.add((idx[0], idx[1], distSq(input[idx[0]], input[idx[1]])))
  dists.sort((a, b) => cmp(a.z, b.z))
  for comb in dists:
    let netA = networks[comb.x]
    let netB = networks[comb.y]
    if netA == netB:
      continue
    netSizes[netA] = netSizes[netA] + netSizes[netB]
    netSizes[netB] = 0
    networks.replace(netB, netA)
    if netSizes[netA] == input.len:
      return input[comb.x].x * input[comb.y].x

when isMainModule:
  echo prepareInput("Aoc08a.txt")
  echo $part1(prepareInput("Aoc08b.txt"))
  echo $part2(prepareInput("Aoc08b.txt"))
