module PadrinoExample
  class App < Padrino::Application
    register Padrino::Rendering
    register Padrino::Helpers

    layout :application
  end
end
