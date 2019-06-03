# XmlToCsv

## Convert XML document into a CSV file

We assume that the XML document contains an array with several sibling elements (often not at the root level), each such element will produce one CSV row.
This array could be present on the root level, or deeper. In the source code, we assume the array elements are `<helpdesk-ticket>`, located under `<helpdesk-tickets>`.
These elements should contain similar (although not necessary identical) structure of nested sub-elements.
Nested sub-element names are dot-concatenated.

_What do you mean "not necessary identical"?_ 

Elements of the array could contain different sets of keys.
To make sure none are missed, all elements are traversed, and a union of keys is produced.
As a result,  all possible keys are used as CSV headers.
If an element does not contain a key, an empty value is emitted.

## Sub-element with multiple occurrences?
    
In our code, each of CSV rows may contain zero to many notes.
Solution we decided to use is to convert notes into a separate CSV file.
Key "display-id" is referring to the main CSV file (has to be unique there).

This is the same approach as in relational databases: child table with a foreign key pointing to the parent table.


## Usage

This project serves as an example. Values are hardwired,
I believe it is far easier to derive a new project than to generalize
by converting those values into parameters.

```
iex -S mix
> XmlToCsv.convert_tickets("t.xml", ".")
> Path.wildcard("../input/Tickets*.xml") |> Enum.each(&XmlToCsv.convert_tickets(&1, "../output/"))
```

## References (with thanks!)
* [XmlToMap](https://github.com/homanchou/elixir-xml-to-map) creates a nested Map data structure from an XML string
* [CSV](https://github.com/beatrichartz/csv) - we use only the encoding logic
* FlattenNestedMap was adapted from [this Gist](https://gist.github.com/sudix/51c610078f39265135a3e1e08b442dea), which was inspired by [Flatten deeply nested Map in Elixir](https://gist.github.com/poteto/e5068020fea38f3594acf1e15cee89fb). See also relevant discussions on StackOverflow and Elixir Forum
