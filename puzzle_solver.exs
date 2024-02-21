defmodule PuzzleSolver do


  # Public function to parse the sequence
  def parse_sequence(sequence) do
    sequence
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce({[], [], []}, fn {char, index}, {unknowns, errors, operationals} ->
      case char do
        "?" -> {[index | unknowns], errors, operationals}
        "#" -> {unknowns, [index | errors], operationals}
        "." -> {unknowns, errors, [index | operationals]}
        _ -> {unknowns, errors, operationals} # Ignore any other character
      end
    end)
    |> map_lists_to_indexes()
  end

  # Helper function to convert lists to indexes for easier handling later
  defp map_lists_to_indexes({unknowns, errors, operationals}) do
    %{
      unknowns: Enum.reverse(unknowns),
      errors: Enum.reverse(errors),
      operationals: Enum.reverse(operationals)
    }
  end

  # Generates all possible configurations for the sequence's unknown segments
  def generate_configurations(sequence, %{unknowns: unknowns} = _parsed) do
    # Calculate the total number of combinations
    total_combinations = :math.pow(2, length(unknowns))
    |> trunc()

    # Generate all combinations
    0..(total_combinations - 1)
    |> Enum.map(&generate_combination(sequence, unknowns, &1))
  end

  # Helper function to generate a specific combination based on a binary representation
  defp generate_combination(sequence, unknowns, combination_index) do
    binary_representation = Integer.to_string(combination_index, 2)
                            |> String.pad_leading(length(unknowns), "0")
                            |> String.graphemes()

    Enum.zip(unknowns, binary_representation)
    |> Enum.reduce(sequence, fn {index, char}, acc_sequence ->
      replacement_char = if char == "1", do: "#", else: "."
      replace_at_index(acc_sequence, index, replacement_char)
    end)
  end


  # Helper function to replace a character at a specific index in the sequence
  defp replace_at_index(sequence, index, replacement_char) do
    String.split(sequence, "", trim: true)
    |> Enum.with_index()
    |> Enum.map(fn {char, idx} -> if idx == index, do: replacement_char, else: char end)
    |> Enum.join("")
  end


# Updated function to validate configurations against the error pattern
def validate_configurations(configurations, pattern) do
  Enum.filter(configurations, &matches_pattern?(&1, pattern))
end

  # Corrected matches_pattern? function to accurately handle non-consecutive errors
  defp matches_pattern?(configuration, pattern) do
    errors = String.graphemes(configuration)
    |> Enum.chunk_by(& &1 == "#")
    |> Enum.filter(fn chunk -> Enum.at(chunk, 0) == "#" end)
    |> Enum.map(&Enum.count(&1))

    errors == pattern
  end


# High-level function to solve the puzzle
def solve_puzzle(sequence, pattern) do
  parsed = parse_sequence(sequence)
  configurations = generate_configurations(sequence, parsed)
  valid_configurations = validate_configurations(configurations, pattern)

  valid_configurations
end


  # Function to repeat the sequence and pattern N times
  def repeat_sequence_pattern(sequence, pattern, n) when n > 0 do
    repeated_sequence = Enum.reduce(1..n, "", fn _i, acc ->
      acc <> (if acc == "", do: "", else: "?") <> sequence
    end)

    # Assemble the repeated pattern
    repeated_pattern = List.duplicate(pattern, n) |> List.flatten()

    {repeated_sequence, repeated_pattern}
  end

  # Function to measure median execution time over a hundred runs
  def solve_time(sequence, pattern) do
    # Collect execution times for a hundred runs
    times = Enum.map(1..100, fn _ ->
      {time, _result} = :timer.tc(fn -> solve_puzzle(sequence, pattern) end)
      time
    end)

    # Sort the times to prepare for median calculation
    sorted_times = Enum.sort(times)

    # Calculate the median time
    median_time = calculate_median(sorted_times)

    IO.puts("Median execution time: #{median_time / 1_000_000.0} seconds")
    # Optionally, return the median time if needed
    median_time / 1_000_000.0
  end

  # Helper function to calculate the median of a list of times
  defp calculate_median(times) do
    len = length(times)
    mid = div(len, 2)

    if rem(len, 2) == 1 do
      # If odd, return the middle element
      Enum.at(times, mid)
    else
      # If even, return the average of the two middle elements
      (Enum.at(times, mid - 1) + Enum.at(times, mid)) / 2
    end
  end


end
