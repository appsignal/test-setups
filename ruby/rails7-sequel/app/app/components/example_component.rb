class ExampleComponent < ViewComponent::Base
  erb_template <<-ERB
    <h3>I am a ViewComponent! Just <%= @pastime %> here, please ignore me.</h3>
  ERB

  def initialize(pastime:)
    @pastime = pastime
  end
end
