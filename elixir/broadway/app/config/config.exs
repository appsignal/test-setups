import Config

import_config "appsignal.exs"

if config_env() == :test do
  import_config "test.exs"
end
