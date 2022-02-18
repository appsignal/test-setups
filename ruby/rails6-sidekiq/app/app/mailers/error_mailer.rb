class ErrorMailer < ApplicationMailer
  def test(*args)
    @args = args
    mail(
      :to => "test@example.com",
      :subject => "Error from My Awesome Site"
    )
  end
end
