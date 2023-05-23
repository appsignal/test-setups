defmodule Mix.Tasks.Spans do
  use Mix.Task
  alias Appsignal.{Span, Tracer}

  def run(_) do
    Application.ensure_all_started(:appsignal)

    create_span(1)
  end

    def create_span(i) do
     #IO.puts "Create span #{i}"
      Task.start(fn ->
       root =
         "web"
         |> Tracer.create_span()
	 |> Span.set_attribute("appsignal:category", "call.phoenix_endpoint")
         |> Span.set_name("HomepageController#show")
         |> Span.set_attribute("string", "value")
         |> Span.set_attribute("int", 1)
         |> Span.set_attribute("bool", true)
         |> Span.set_attribute("float", 8.1)
         |> Span.set_attribute("revision", "aaaa")
         |> Span.set_sample_data("params", %{
           param_key: "value",
           filtered_param_key: "value",
           nested_param: %{
             nested_param_key: "value",
             nested_filtered_param_key: "value"
           }
         })
         |> Span.set_sample_data("session_data", %{
           session_key: "value",
           filtered_session_key: "value",
           nested_session: %{
             nested_session_key: "value",
             nested_filtered_session_key: "value"
           }
         })

       child_1 =
         ""
         |> Tracer.create_span(root)
         |> Span.set_name("child-span")
         |> Span.set_attribute("key", "value")
         |> Span.set_attribute("appsignal:category", "query")

       Tracer.close_span(child_1)

       child_2 =
         ""
         |> Tracer.create_span(root)
         |> Span.set_name("child-span")
         |> Span.set_attribute("key", "value")
         |> Span.set_attribute("appsignal:category", "query")

       Tracer.close_span(child_2)

       Tracer.close_span(root)

     end)
      
    create_span(i + 1)
   end
end
