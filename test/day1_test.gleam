import gleeunit/should
import day1/day1

pub fn it_should_handle_text_and_numbers_test() {
  let input = "5onesixsevenphxtmlqhzfcjxrknpv"

  input
  |> day1.get_digit(True)
  |> should.equal(57)
}

pub fn it_should_correctly_parse_nested_values_test() {
  let input = "seven148oneightd"

  input
  |> day1.get_digit(True)
  |> should.equal(78)
}
