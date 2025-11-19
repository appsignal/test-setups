{application,ash_appsignal,
             [{compile_env,[{appsignal,[appsignal_monitor],error}]},
              {optional_applications,[]},
              {applications,[kernel,stdlib,elixir,logger,ash,appsignal]},
              {description,"The AppSignal APM integration for Ash Framework\n"},
              {modules,['Elixir.AshAppsignal']},
              {registered,[]},
              {vsn,"0.1.3"}]}.
