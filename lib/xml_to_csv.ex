defmodule XmlToCsv do
  @moduledoc """
  Documentation for XmlToCsv.
  """

  @bom :unicode.encoding_to_bom(:utf8)

  @doc """
  Hello world.

  ## Examples

      iex> XmlToCsv.hello()
      :world

  """
  def hello do
    :world
  end

  # protocol String.Chars not implemented for %{}
  def convert(path) do
    xml_string = File.read!(path)
    # {:ok, file} = File.open(path, [:read, :raw])
    # xml_string = IO.read(file, :all)
    # File.close(file)

    map = XmlToMap.naive_map(xml_string)

    ##CSV.encode(map) |> Enum.each(&IO.puts(&1))
    #map["forum-categories"]["forum-category"]["forums"]["forum"] |> Enum.map(&FlattenNestedMap.flatten_with_parent_key(&1)) |> CSV.Encoding.Encoder.encode(headers: true) |> Enum.to_list()

    csv = map["helpdesk-tickets"]["helpdesk-ticket"]
    |> Enum.map(&FlattenNestedMap.flatten_with_parent_key(&1))
    |> CSV.Encoding.Encoder.encode(separator: ?\t, headers: ["id", "subject", "description"]) |> Enum.take(10000)
#    |> CSV.Encoding.Encoder.encode(headers: true) |> Enum.to_list()

    # prepend with a BOM to convince Excel this is really a UTF-8
    # Or use UTF-16 little-endian, see https://underthehood.meltwater.com/blog/2018/08/08/excel-friendly-csv-exports-with-elixir/
    File.write!("out.csv", [@bom | csv], [:write])
  end
end
