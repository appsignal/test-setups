defmodule Helpdesk.Support.Ticket do
  use Ash.Resource,
    otp_app: :app,
    domain: Helpdesk.Support
end
