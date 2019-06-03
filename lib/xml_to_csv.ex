defmodule XmlToCsv do
  @moduledoc """
  Convert XML document into a CSV file.

  This module assumes that the XML document contains several sibling elements,
  where each element will produce one CSV row.
  These elements should contain similar (although not necessary identical)
  structure of nested sub-elements.
  Element names are dot-concatenated.
  """

  # Start the output file with a BOM to convince Excel this is really a UTF-8
  # Or use UTF-16 little-endian, see https://underthehood.meltwater.com/blog/2018/08/08/excel-friendly-csv-exports-with-elixir/
  @bom :unicode.encoding_to_bom(:utf8)

  @spec maps_to_csv([map]) :: [String.t()]
  def maps_to_csv(list_of_nested_maps) do
    # Each map is flattened independently
    list_of_flat_maps =
      list_of_nested_maps
      |> Enum.map(&FlattenNestedMap.flatten_with_parent_key(&1))

    # scan all maps, use union of their keys as CSV headers
    headers =
      list_of_flat_maps
      |> Enum.reduce(MapSet.new(), fn map, acc -> MapSet.union(acc, MapSet.new(Map.keys(map))) end)
      |> MapSet.to_list()
      |> Enum.sort()

    csv =
      list_of_flat_maps
      |> CSV.Encoding.Encoder.encode(separator: ?\,, headers: headers)
      |> Enum.to_list()
    #  or  |> CSV.Encoding.Encoder.encode(headers: true) |> Enum.take(10)

    csv
  end

  @doc """
  Take all element["notes"]["helpdesk-note"] and convert into top level map.
  Use element["display-id"] as an index.
  """
  def maps_to_notes_map(list_of_nested_maps) do
    list_of_notes = list_of_nested_maps |> Enum.reduce([], fn el, acc ->
      acc ++ get_notes(el) # yes, I know: appending to the end is not efficient
    end)
    #IO.puts("#{inspect list_of_notes}")
    list_of_notes
  end

  defp get_notes(%{"display-id" => id, "notes" => %{"helpdesk-note" => notes }}) when is_list(notes) do
    notes |> Enum.with_index |> Enum.map(fn {note, index} -> %{"display-id" => id, "index_of_note" => index, "note" => note} end)
  end
  defp get_notes(%{"display-id" => id, "notes" => %{"helpdesk-note" => note }}) when is_map(note) do
    [%{"display-id" => id, "index_of_note" => 0, "note" => note}]
  end
  defp get_notes(_) do
    []
  end

  def convert_tickets(xml_path, csv_dir) do
    xml_string = File.read!(xml_path)
    map = XmlToMap.naive_map(xml_string)
    # Locate an element that contains a list, to be converted into csv rows.
    conversion_root = map["helpdesk-tickets"]["helpdesk-ticket"]
    # conversion_root = map["forum-categories"]["forum-category"]["forums"]["forum"]
    csv = maps_to_csv(conversion_root)

    basename = Path.basename(xml_path, ".xml")
    csv_path = Path.join([csv_dir, basename <> ".csv"])
    IO.puts("#{xml_path} converted into #{csv_path}")
    # Prepend with a BOM to convince Excel this is really a UTF-8
    File.write!(csv_path, [@bom | csv], [:write])

    # Produce a second CSV, capturing element["notes"]["helpdesk-note"].
    # Use element["display-id"] as an index
    list_of_notes = maps_to_notes_map(conversion_root)
    notes_csv = maps_to_csv(list_of_notes)

    notes_csv_path = Path.join([csv_dir, basename <> "_notes.csv"])
    IO.puts("#{xml_path} converted into #{notes_csv_path}")
    # Prepend with a BOM to convince Excel this is really a UTF-8
    File.write!(notes_csv_path, [@bom | notes_csv], [:write])

  end

  # iex -S mix
  # XmlToCsv.convert_tickets("t.xml", ".")
  # Path.wildcard("../input/Tickets*.xml") |> Enum.each(&XmlToCsv.convert_tickets(&1, "../output/"))
end
