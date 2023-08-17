if APP.backend?
  RSpec.describe "Backend for the test setup #{APP}" do
    it "has a slow endpoint" do
      slow_url = APP.url("/slow")

      expect {
        HTTP.follow.timeout(2).get(slow_url)
      }.to(
        raise_error(HTTP::TimeoutError),
        "Expected request to timeout, it did not"
      )

      response = HTTP.follow.get(slow_url)

      expect(response).to have_status(200)
    end

    it "has an error endpoint" do
      response = HTTP.follow.get(APP.url("/error?error=yes"))

      expect(response).to have_status(500)
    end
  end
end
