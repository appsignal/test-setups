defmodule BroadwayExample.PipelineTest do
  use ExUnit.Case, async: false

  alias Broadway.Message
  alias BroadwayExample.{Event, Pipeline}

  describe "handle_message/3" do
    test "converts the amount and routes ordinary payments to the default batcher" do
      message = Pipeline.handle_message(:default, message(%{amount_cents: 1_250}), nil)

      assert message.data.amount == 12.5
      assert message.batcher == :default
    end

    test "routes large payments to the suspicious batcher" do
      message = Pipeline.handle_message(:default, message(%{amount_cents: 250_000}), nil)

      assert message.batcher == :suspicious
    end

    test "batches per currency" do
      message = Pipeline.handle_message(:default, message(%{currency: "GBP"}), nil)

      assert message.batch_key == "GBP"
    end

    test "raises for messages flagged to fail" do
      assert_raise BroadwayExample.ProcessingError, fn ->
        Pipeline.handle_message(:default, message(%{fail: true}), nil)
      end
    end
  end

  defp message(overrides) do
    %Message{
      data: Event.random(overrides),
      acknowledger: BroadwayExample.Acknowledger.init()
    }
  end
end
