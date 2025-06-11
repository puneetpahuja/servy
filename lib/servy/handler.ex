defmodule Servy.Handler do
  @moduledoc "Handles HTTP requests."
  alias Servy.BearController
  alias Servy.Conv
  alias Servy.Parser
  alias Servy.Plugins

  @pages_path Path.expand("pages", File.cwd!())

  @doc "Transforms the request into a response."
  def handle(request) do
    request
    |> Parser.parse()
    |> Plugins.rewrite_path()
    |> Plugins.log()
    |> route
    # |> Plugins.emojify
    |> Plugins.track()
    |> format_response
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "POST", path: "/bears", params: params} = conv) do
    BearController.create(conv, params)
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    route_file("form.html", conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "DELETE", path: "/bears/" <> id} = conv) do
    BearController.delete(conv, id)
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    route_file("about.html", conv)
  end

  def route(%Conv{method: "GET", path: "/pages/" <> page_name} = conv) do
    route_file(page_name <> ".html", conv)
  end

  def route(%Conv{path: path} = conv) do
    %{conv | status: 404, resp_body: "No #{path} here!"}
  end

  def route_file(filename, %Conv{} = conv) do
    @pages_path
    |> Path.join(filename)
    |> File.read()
    |> handle_file(conv)
  end

  def handle_file({:ok, content}, %Conv{} = conv) do
    %{conv | status: 200, resp_body: content}
  end

  def handle_file({:error, :enoent}, %Conv{} = conv) do
    %{conv | status: 404, resp_body: "File not found!"}
  end

  def handle_file({:error, reason}, %Conv{} = conv) do
    %{conv | status: 500, resp_body: "File error: #{reason}"}
  end

  def format_response(%Conv{resp_body: resp_body} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{byte_size(resp_body)}

    #{resp_body}
    """
  end
end

request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

request = """
GET /bears/2 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

request = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

request = """
GET /wildlife HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

request = """
GET /bears?id=2 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

request = """
DELETE /bears/4 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

request = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

request = """
GET /bears/new HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

request = """
GET /pages/about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

request = """
POST /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: application/x-www-form-urlencoded
Content-Length: 21

name=Baloo&type=Brown
"""

response = Servy.Handler.handle(request)
IO.puts(response)
