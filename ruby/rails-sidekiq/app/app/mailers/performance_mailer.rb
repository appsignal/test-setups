class PerformanceMailer < ApplicationMailer
  def test(*_args)
    mail(
      :to => "test@example.com",
      :subject => "Welcome to My Awesome Site"
    )
  end
end
