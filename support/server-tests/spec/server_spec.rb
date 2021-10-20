APP = ENV.fetch("APP_NAME")
BASE_URL = ENV.fetch("APP_URL")

RSpec.describe "Server for the test setup #{APP}" do
  it "has an index page" do
    response = HTTP.get(BASE_URL)

    expect(response.status).to eql(200), [
      "Expected status code 200, got #{response.status}",
      "Response body:",
      response.body
    ].join("\n")
  end
end
