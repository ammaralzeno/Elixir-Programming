defmodule ListOps do

  # Return the length of the list
  def leng([]), do: 0
  def leng([_head | tail]), do: 1 + leng(tail)

  # Return a list of all even numbers
  def even([]), do: []
  def even([head | tail]) when rem(head, 2) == 0, do: [head | even(tail)]
  def even([_head | tail]), do: even(tail)

  # Return a list where each element has been incremented by a value
  def inc([], _value), do: []
  def inc([head | tail], value), do: [head + value | inc(tail, value)]

  # Return the sum of all values of the list
  def sum([]), do: 0
  def sum([head | tail]), do: head + sum(tail)

  # Return a list where each element has been decremented by a value
  def dec([], _value), do: []
  def dec([head | tail], value), do: [head - value | dec(tail, value)]

  # Return a list where each element has been multiplied by a value
  def mul([], _value), do: []
  def mul([head | tail], value), do: [head * value | mul(tail, value)]

  # Return a list of all odd numbers
  def odd([]), do: []
  def odd([head | tail]) when rem(head, 2) != 0, do: [head | odd(tail)]
  def odd([_head | tail]), do: odd(tail)

  # Return a list with the result of taking the remainder of dividing the original by some integer
  def remainder([], _value), do: []
  def remainder([head | tail], value), do: [rem(head, value) | remainder(tail, value)]

  # Return the product of all values of the list
  def prod([]), do: 1  # The product of an empty list is defined as 1
  def prod([head | tail]), do: head * prod(tail)

  # Return a list of all numbers that are evenly divisible by some number
  def divide([], _divisor), do: []
  def divide([head | tail], divisor) when rem(head, divisor) == 0, do: [head | divide(tail, divisor)]
  def divide([_head | tail], divisor), do: divide(tail, divisor)

end
