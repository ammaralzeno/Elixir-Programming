defmodule SeedTransformer do
  def parse_input(input) do
    segments = String.trim(input)
               |> String.split("\n\n")

    seeds = parse_seeds(Enum.at(segments, 0))
    maps = Enum.drop(segments, 1) |> Enum.map(&parse_map/1)

    %{seeds: seeds, maps: maps}
  end

  defp parse_seeds(seeds_string) do
    seeds_string
    |> String.split(": ")
    |> Enum.at(1)
    |> String.split(" ")
    |> Enum.map(&parse_integer/1)
  end

  defp parse_map(map_string) do
    map_string
    |> String.split("\n", trim: true)
    |> Enum.drop(1)
    |> Enum.map(&parse_rule/1)
  end

  defp parse_rule(rule_string) do
    [dest, source, range] = String.split(rule_string, " ")
    {parse_integer(dest), parse_integer(source), parse_integer(range)}
  end

  defp parse_integer(string) do
    case Integer.parse(string) do
      {number, _} -> number
      :error -> raise ArgumentError, "Cannot parse '#{string}' to an integer"
    end
  end

  def find_lowest_location_number(input) do
    seeds = input[:seeds]
    maps = input[:maps]

    seeds
    |> Enum.map(&process_seed_through_maps(&1, maps))
    |> Enum.min()
  end

  def process_seed_through_maps(seed, maps) do
    Enum.reduce(maps, seed, fn map, acc ->
      new_acc = convert_number_through_map(acc, map)
      IO.puts("Transforming seed #{seed}: #{acc} -> #{new_acc}")
      new_acc
    end)
  end

  def convert_number_through_map(number, map) do
    Enum.reduce_while(map, number, fn {dest_start, src_start, length}, acc ->
      src_end = src_start + length - 1
      dest_end = dest_start + length - 1

      if acc >= src_start and acc <= src_end do
        # Calculate the offset from the start of the source range
        offset = acc - src_start
        # Calculate the new number using the destination start and offset
        new_number = dest_start + offset

        if new_number <= dest_end do
          {:halt, new_number}
        else
          {:halt, dest_end}
        end
      else
        {:cont, acc}
      end
    end)
  end


end
