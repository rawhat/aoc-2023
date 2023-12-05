import day1/day1
import day2/day2
import day3/day3
import day4/day4
import day5/day5
import gleam/int
import gleam/io
import gleam/list

pub type TimeUnit {
  Millisecond
}

@external(erlang, "timer", "tc")
fn time(func: fn() -> anything, unit: TimeUnit) -> #(Int, anything)

fn run(func: fn() -> anything) {
  let #(runtime, _res) = time(func, Millisecond)
  io.println("Completed in: " <> int.to_string(runtime) <> "ms")
}

pub fn main() {
  [
    day1.part_one,
    day1.part_two,
    day2.part_one,
    day2.part_two,
    day3.part_one,
    day3.part_two,
    day4.part_one,
    day4.part_two,
    day5.part_one,
  ]
  // day5.part_two,
  |> list.each(run)
}
