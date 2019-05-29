defmodule XmlToCsvTest do
  use ExUnit.Case
  doctest XmlToCsv

  test "maps_to_csv" do
    list_of_nested_maps = [%{"a" => 1, "b" => %{"ba" => 2}}, %{"a" => 3, "b" => %{"bb" => 4}, "c" => 5}]
    assert XmlToCsv.maps_to_csv(list_of_nested_maps) == ["a,b.ba,b.bb,c\r\n", "1,2,,\r\n", "3,,4,5\r\n"]
  end
end
