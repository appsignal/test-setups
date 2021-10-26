RSpec.describe "Server for the test setup #{APP}" do
  it "has an index page" do
    response = HTTP.get(APP.url)

    expect(response).to have_status(200)
  end
end
