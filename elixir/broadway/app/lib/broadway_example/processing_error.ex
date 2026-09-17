defmodule BroadwayExample.ProcessingError do
  @moduledoc """
  Raised by `BroadwayExample.Pipeline` for messages flagged to fail, so the
  error path can be exercised on demand.
  """

  defexception [:id]

  @impl Exception
  def message(%__MODULE__{id: id}) do
    "Could not process payment #{id}"
  end
end
