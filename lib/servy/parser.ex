defmodule Servy.Parser do
  alias Servy.Conv

  require Logger

  def parse(request) do
    [top, params_str] = String.split(request, "\n\n", parts: 2)
    [request_line | header_lines] = String.split(top, "\n")
    [method, path, _version] = String.split(request_line)
    headers = parse_headers(header_lines)
    params = parse_params(headers["Content-Type"], params_str)

    %Conv{
      method: method,
      path: path,
      params: params,
      headers: headers
    }
  end

  def parse_headers(header_lines) do
    Enum.reduce(header_lines, %{}, fn header_line, headers ->
      [key, value] = String.split(header_line, ": ", parts: 2)
      Map.put(headers, key, value)
    end)
  end

  def parse_params("application/x-www-form-urlencoded", params_str) do
    params_str |> String.trim() |> URI.decode_query()
  end

  def parse_params(_, _), do: %{}
end
