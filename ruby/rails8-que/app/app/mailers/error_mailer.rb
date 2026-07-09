class ErrorMailer < ApplicationMailer
  def test(*args)
    Rails.error.handle do
      1 + '1' # raises TypeError
    end
    @args = args
    mail(
      :to => "test@example.com",
      :subject => "Error from My Awesome Site"
    )
  end
end
