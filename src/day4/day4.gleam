import gleam/dict.{Dict}
import gleam/int
import gleam/io
import gleam/float
import gleam/list
import gleam/regex
import gleam/string
import simplifile

fn parse_input() {
  let assert Ok(str) = simplifile.read("./src/day4/input.txt")
  str
  |> string.trim
  |> string.split("\n")
}

pub type Card {
  Card(id: Int, winning_numbers: List(Int), numbers: List(Int))
}

fn parse_card(str: String) -> Card {
  let assert [card_with_number, numbers] = string.split(str, ": ")
  let assert [winning_numbers, my_numbers] = string.split(numbers, " | ")
  let card_number = string.replace(card_with_number, "Card", "")
  let assert Ok(card_number) = int.parse(string.trim(card_number))

  let options = regex.Options(case_insensitive: False, multi_line: False)
  let assert Ok(re) = regex.compile("(\\d+)", options)

  let winning_matches = regex.scan(re, winning_numbers)
  let numbers_matches = regex.scan(re, my_numbers)

  let winning_numbers =
    list.map(winning_matches, fn(match) {
      let assert Ok(val) = int.parse(match.content)
      val
    })
  let my_numbers =
    list.map(numbers_matches, fn(match) {
      let assert Ok(val) = int.parse(match.content)
      val
    })

  Card(card_number, winning_numbers, numbers: my_numbers)
}

fn matching_numbers(card: Card) -> Int {
  list.fold(card.numbers, 0, fn(amount, number) {
    case list.contains(card.winning_numbers, number) {
      True -> amount + 1
      _ -> amount
    }
  })
}

pub fn part_one() {
  let str =
    "Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11"
    |> string.trim
    |> string.split("\n")

  parse_input()
  |> list.map(parse_card)
  |> list.map(fn(card) {
    case matching_numbers(card) {
      0 -> 0
      n -> {
        let assert Ok(val) = int.power(2, int.to_float(n - 1))
        float.round(val)
      }
    }
  })
  |> int.sum
  |> fn(score) { io.println("Amount won from cards: " <> int.to_string(score)) }
}

fn get_total(id: Int, counts: Dict(Int, List(Int)), count: Int) -> Int {
  case dict.get(counts, id) {
    Ok([]) -> count
    Ok(numbers) -> {
      list.fold(numbers, list.length(numbers) + count, fn(count, number) {
        get_total(number, counts, count)
      })
    }
    _ -> -1
  }
}

pub fn part_two() {
  let str = parse_input()

  let all_cards = list.map(str, parse_card)
  let winning_expansions =
    list.fold(all_cards, dict.new(), fn(expansions, card) {
      case matching_numbers(card) {
        0 -> dict.insert(expansions, card.id, [])
        n -> {
          let next_values = list.range(card.id + 1, card.id + n)
          dict.insert(expansions, card.id, next_values)
        }
      }
    })

  list.fold(all_cards, 0, fn(count, card) {
    let card_count = get_total(card.id, winning_expansions, 0)
    count + 1 + card_count
  })
  |> fn(total) {
    io.println("We got " <> int.to_string(total) <> " total cards")
  }
}
