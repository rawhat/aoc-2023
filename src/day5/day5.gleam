import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import simplifile

pub type Range {
  Range(start: Int, end: Int)
}

pub type Mapping {
  Mapping(source_start: Int, destination_start: Int, count: Int)
}

pub type Mappings {
  Mappings(seeds: List(Int), ordered_lookups: List(List(Mapping)))
}

fn parse_dict(str: String) -> List(Mapping) {
  str
  |> string.trim
  |> string.split("\n")
  |> list.drop(1)
  |> list.fold(
    [],
    fn(mappings, row) {
      let assert [destination, source, count] =
        row
        |> string.split(" ")
        |> list.map(fn(val) {
          let assert Ok(val) = int.parse(val)
          val
        })
      [
        Mapping(
          source_start: source,
          destination_start: destination,
          count: count,
        ),
        ..mappings
      ]
    },
  )
}

pub fn parse_input(str: String) -> Mappings {
  let assert [
    seeds,
    seed_to_soil,
    soil_to_fertilizer,
    fertilizer_to_water,
    water_to_light,
    light_to_temperature,
    temperature_to_humidity,
    humidity_to_location,
  ] = string.split(str, "\n\n")
  let seeds =
    seeds
    |> string.replace("seeds: ", "")
    |> string.split(" ")
    |> list.map(fn(val) {
      let assert Ok(val) = int.parse(val)
      val
    })
  let seed_to_soil = parse_dict(seed_to_soil)
  let soil_to_fertilizer = parse_dict(soil_to_fertilizer)
  let fertilizer_to_water = parse_dict(fertilizer_to_water)
  let water_to_light = parse_dict(water_to_light)
  let light_to_temperature = parse_dict(light_to_temperature)
  let temperature_to_humidity = parse_dict(temperature_to_humidity)
  let humidity_to_location = parse_dict(humidity_to_location)

  Mappings(
    seeds,
    [
      seed_to_soil,
      soil_to_fertilizer,
      fertilizer_to_water,
      water_to_light,
      light_to_temperature,
      temperature_to_humidity,
      humidity_to_location,
    ],
  )
}

fn traverse(seed: Int, mappings: Mappings) -> Int {
  let location =
    list.fold(
      mappings.ordered_lookups,
      seed,
      fn(value, lookup) {
        lookup
        |> list.find(fn(mapping) {
          value >= mapping.source_start && value <= mapping.source_start + mapping.count
        })
        |> result.map(fn(mapping) {
          let diff = value - mapping.source_start
          mapping.destination_start + diff
        })
        |> result.unwrap(value)
      },
    )

  location
}

pub fn part_one() {
  let assert Ok(input) = simplifile.read("./src/day5/input.txt")
  let mappings = parse_input(input)

  mappings.seeds
  |> list.map(traverse(_, mappings))
  |> list.reduce(int.min)
  |> fn(min) {
    let assert Ok(min) = min
    io.println("Smallest location value is: " <> int.to_string(min))
  }
}

pub fn part_two() {
  let assert Ok(input) = simplifile.read("./src/day5/input.txt")
  let mappings = parse_input(input)

  mappings.seeds
  |> list.window_by_2
  |> iterator.from_list
  // obv not gonna work...
  |> iterator.flat_map(fn(window) {
    let assert #(start, count) = window
    iterator.range(start, start + count - 1)
  })
  |> iterator.fold(
    None,
    fn(min, value) {
      let next = traverse(value, mappings)
      min
      |> option.map(fn(min) { int.min(min, next) })
      |> option.or(Some(next))
    },
  )
  |> fn(min) {
    let assert Some(min) = min
    io.println("Smallest location in range is: " <> int.to_string(min))
  }
}

const sample = "seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4"
