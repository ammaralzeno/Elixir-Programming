defmodule ListOps2 do


def map2([], _func), do: []
def map2([head | tail], func) do
  [func.(head) | map2(tail, func)]
end

def reduce2([], acc, _func), do: acc
def reduce2([head | tail], acc, func) do
  reduce2(tail, func.(head, acc), func)
end

def filter2([], _func), do: []
def filter2([head | tail], func) do
  if func.(head) do
    [head | filter2(tail, func)]
  else
    filter2(tail, func)
  end
end



def leng(list) do
  list |> reduce2(0, fn _elem, acc -> acc + 1 end)
end

def even(list) do
  list |> filter2(fn x -> rem(x, 2) == 0 end)
end

def inc(list, value) do
  list |> map2(fn x -> x + value end)
end

def sum(list) do
  list |> reduce2(0, &(&1 + &2))
end

def dec(list, value) do
  list |> map2(fn x -> x - value end)
end

def mul(list, value) do
  list |> map2(fn x -> x * value end)
end

def odd(list) do
  list |> filter2(fn x -> rem(x, 2) != 0 end)
end

def remainder(list, value) do
  list |> map2(fn x -> rem(x, value) end)
end

def prod(list) do
  list |> reduce2(1, &(&1 * &2))
end

def divide(list, divisor) do
  list |> filter2(fn x -> rem(x, divisor) == 0 end)
end

def sum_of_squares_less_than_n(list, n) do
  list
  |> filter2(fn x -> x < n end)
  |> map2(fn x -> x * x end)
  |> sum()
end


end






def parse_sequence(sequence_string) do
  [sequence_desc, error_pattern_desc] = String.split(sequence_string, " ")
  sequence = String.graphemes(sequence_desc)
  error_pattern = parse_error_pattern(error_pattern_desc)

  {sequence, error_pattern}
end

defp parse_error_pattern(pattern) do
  pattern
  |> String.trim_trailing("]")
  |> String.trim_leading("[")
  |> String.split(",")
  |> Enum.map(&parse_integer/1)
end

defp parse_integer(num_str) do
  case Integer.parse(num_str) do
    {num, _} -> num
    :error -> {:error, "Invalid number: #{num_str}"}
  end
end
