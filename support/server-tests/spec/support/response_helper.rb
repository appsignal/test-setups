RSpec::Matchers.define :have_status do |expected|
  match do |actual|
    actual.status == expected
  end

  failure_message do |actual|
    "Expected response to have status code " \
      "#{expected}, got #{actual.status.to_i}\n" \
      "Response body:\n#{actual.body}"
  end
end
