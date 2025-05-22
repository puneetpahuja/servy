defmodule Servy.Parser do
  alias Servy.Conv

  require Logger

  def parse(request) do
    [top, params_str] = String.split(request, "\n\n", parts: 2)
    [request_line | header_lines] = String.split(top, "\n")
    [method, path, _version] = String.split(request_line)
    headers = parse_headers(header_lines, %{})
    params = parse_params(headers["Content-Type"], params_str)

    %Conv{
      method: method,
      path: path,
      params: params,
      headers: headers
    }
  end

  def parse_headers([h | t], headers) do
    [key, value] = String.split(h, ": ", parts: 2)
    headers = Map.put(headers, key, value)
    parse_headers(t, headers)
  end

  def parse_headers([], headers), do: headers

  def parse_params("application/x-www-form-urlencoded", params_str) do
    params_str |> String.trim() |> URI.decode_query()
  end

  def parse_params(_, _), do: %{}
end
