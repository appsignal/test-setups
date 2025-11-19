defmodule App.Resource.Ticket do
  use Ash.Resource,
    otp_app: :app,
    domain: App.Resource,
    data_layer: Ash.DataLayer.Ets
end
