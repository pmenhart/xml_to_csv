defmodule FlattenNestedMap do
  @doc """
  flatten given map with nested key.

  All keys must be atom or binary. Returns map.
  Found in https://gist.github.com/sudix/51c610078f39265135a3e1e08b442dea

  Changes:
  * nested empty maps are replaced with empty string
  * lists are replaced with first element (DANGEROUS!!!)

  ## Examples
  iex> FlattenNestedMap.flatten_with_parent_key(%{a: 1, b: %{ba: 21, bb: %{bba: 241}}, c: 3})
  %{:a => 1, :c => 3, "b.ba" => 21, "b.bb.bba" => 241}

  iex> FlattenNestedMap.flatten_with_parent_key(%{"a" => 1, "b" => %{}})
  # original: %{"a" => 1}
  %{"a" => 1, "b" => ""}

  iex> FlattenNestedMap.flatten_with_parent_key(%{"a" => 1, "b" => %{"ba" => 21, "bb" => %{}}})
  %{"a" => 1, "b.ba" => 21, "b.bb" => ""}

  iex> FlattenNestedMap.flatten_with_parent_key(%{a: 1, b: %{bbb: %{}}, c: %{}})
  %{:a => 1, "c" => "", "b.bbb" => ""}

  iex> FlattenNestedMap.flatten_with_parent_key(%{a: 1, b: %{bbb: [11, 22, 33]}, c: %{}})
  %{:a => 1, "c" => "", "b.bbb" => 11}

  """
  @spec flatten_with_parent_key(map) :: map
  def flatten_with_parent_key(map) when is_map(map) do
    map
    |> Map.to_list()
    |> to_flat_map(%{})
  end

  defp to_flat_map([{pk, %{} = v} | t], acc) do
    v |> to_list(pk) |> to_flat_map(to_flat_map(t, acc))
  end
  defp to_flat_map([{k, v} | t], acc), do: to_flat_map(t, Map.put_new(acc, k, v))
  defp to_flat_map([], acc), do: acc

  defp to_list(map, pk) when is_atom(pk), do: to_list(map, Atom.to_string(pk))
  # Diversion from original gist: nested empty maps are replaced with empty string
  defp to_list(map, pk) when is_binary(pk) and map == %{}, do: [{pk, ""}]
  defp to_list(map, pk) when is_binary(pk), do: Enum.map(map, &update_key(pk, &1))

  defp update_key(pk, {k, v} = _val) when is_atom(k), do: update_key(pk, {Atom.to_string(k), v})
  # take head of a list and ignore the rest
  defp update_key(pk, {k, [h | _t]} = _val) when is_binary(k), do: {"#{pk}.#{k}", h}
  defp update_key(pk, {k, v} = _val) when is_binary(k), do: {"#{pk}.#{k}", v}
end
