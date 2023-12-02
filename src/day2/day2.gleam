import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import simplifile

pub fn parse_input() -> List(String) {
  let assert Ok(input) =
    simplifile.read("./src/day2/input.txt")
    |> result.map(string.trim)
    |> result.map(string.split(_, "\n"))

  input
}

pub type Game {
  Game(id: Int, red: Int, green: Int, blue: Int)
}

pub fn get_game_results(str: String) -> List(Game) {
  let assert [game_with_id, results] = string.split(str, ": ")
  let assert "Game " <> id = game_with_id
  let assert Ok(id) = int.parse(id)
  let game_results = string.split(results, "; ")

  game_results
  |> list.map(fn(game_result) {
    game_result
    |> string.split(", ")
    |> list.fold(Game(id, 0, 0, 0), fn(game, color_count) {
      let assert [count, color] = string.split(color_count, " ")
      let assert Ok(count) = int.parse(count)

      case color {
        "green" -> Game(..game, green: game.green + count)
        "red" -> Game(..game, red: game.red + count)
        "blue" -> Game(..game, blue: game.blue + count)
        _ -> game
      }
    })
  })
}

pub fn part_one() {
  let valid_game = Game(id: 0, red: 12, green: 13, blue: 14)
  parse_input()
  |> list.map(get_game_results)
  |> list.filter(fn(games) {
    list.all(games, fn(game) {
      game.red <= valid_game.red && game.green <= valid_game.green && game.blue <= valid_game.blue
    })
  })
  |> list.map(fn(games) {
    let assert Ok(first) = list.first(games)
    first.id
  })
  |> set.from_list
  |> set.fold(0, fn(acc, num) { acc + num })
  |> fn(res) { io.println("Sum of valid game IDs is: " <> int.to_string(res)) }
}

pub fn part_two() {
  parse_input()
  |> list.map(get_game_results)
  |> list.map(fn(games) {
    let assert Ok(res) =
      list.reduce(games, fn(prev, next) {
        Game(
          ..prev,
          red: int.max(prev.red, next.red),
          green: int.max(prev.green, next.green),
          blue: int.max(prev.blue, next.blue),
        )
      })
    res
  })
  |> list.map(fn(game) { game.red * game.green * game.blue })
  |> int.sum
  |> fn(res) { io.println("Sum of game powers is: " <> int.to_string(res)) }
}
