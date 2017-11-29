defmodule Tableize do
  @moduledoc """
  Prints tabular data on terminal output.

  The function Tablelize.print/1 takes a list of keyword lists, and prints the
  table on standard output. Each element in the keyword lists must be printable
  as a string through Kernel.to_string/1.

  ## Examples

    iex> data = [[city: "Paris", country: "France", planet: "Earth"], [city: "San Francisco", country: "United States of America", planet: "Earth"], [city: "Arcadia", country: "N/A", planet: "Gallifrey"]]
    iex> Tableize.print(data)
    :ok
    
    iex> data = [[city: "Paris", country: "France", planet: "Earth"], [city: "San Francisco", country: "United States of America", planet: "Earth"], [city: "Arcadia", country: "N/A", planet: "Gallifrey"]]
    iex> import ExUnit.CaptureIO
    iex> capture_io fn -> Tableize.print(data) end
    "CITY            COUNTRY                    PLANET   \\nParis           France                     Earth    \\nSan Francisco   United States of America   Earth    \\nArcadia         N/A                        Gallifrey\\n"

    iex> Tableize.print([])
    :ok

    The method may return an error in the following cases:

    iex> Tableize.print([[firstname: "Antoine"], [firstname: "Doctor", lastname: "Who"]])
    {:error, "all rows must be of the same size"}

    iex> Tableize.print([[firstname: %{unprintable: "value"}]])
    {:error, "cannot marshal some value into String"}
  
  """

  # No more rows in the table
  defp build([], _, _), do: {:ok, nil}

  # Any row in the table
  defp build([line | rest] = _data, columns, sizes) do
    cond do
      length(line) != columns -> {:error, "all rows must be of the same size"}
      true ->
        # Pad values to match the maximum length for each column
        # Add padding
        output =
          line
          |> Enum.map(
            fn {k, v} ->
              v
              |> to_string
              |> String.pad_trailing(Keyword.get(sizes, k))
            end
          )
          |> Enum.join("   ")

        case build(rest, columns, sizes) do
          {:ok, nil} -> {:ok, [output]}
          {:ok, rows} -> {:ok, [output] ++ rows}
          {:error, message} -> {:error, message}
        end
    end
  end

  # Build each row as a list of lists
  defp build([line | _] = data) when is_list(data) and length(data) > 0 do
    # Extract header labels from first row
    headers =
      line
      |> Keyword.keys
      |> Enum.map(&Atom.to_string/1)
      |> Enum.map(&String.upcase/1)

    table = [List.zip([Keyword.keys(line), headers])] ++ data
    
    # Determine maximum size for each column
    try do
      sizes =
        table
        |> Enum.reduce([],
          fn x, y ->
            Keyword.merge(x, y,
              fn _k, x, y ->
                if String.length(to_string(x)) > String.length(to_string(y)), do: x, else: y
              end
            )
          end
        )
        |> Enum.map(fn {k, v} -> {k, String.length(to_string(v))} end)

      # Start building
      build(table, length(line), sizes)
    rescue
      Protocol.UndefinedError -> {:error, "cannot marshal some value into String"}
    end
  end

  # Build table for an empty list
  defp build(data) when is_list(data), do: {:ok, []}

  # Print the table on screen
  def print(data) when is_list(data) do
    case build(data) do
      {:ok, rows} ->
        for line <- rows do
          IO.puts(line)
        end

        :ok
      error -> error
    end
  end
end
