defmodule App.Resource do
  use Ash.Domain,
    otp_app: :app

  resources do
    resource App.Resource.Ticket
  end
end
