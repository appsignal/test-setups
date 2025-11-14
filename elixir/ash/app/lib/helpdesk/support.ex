defmodule Helpdesk.Support do
  use Ash.Domain,
    otp_app: :app

  resources do
    resource(Helpdesk.Support.Ticket)
  end
end
