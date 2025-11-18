World(RSpec::Matchers)

Given("I have uploaded an image for AI description") do
  image_path = Rails.root.join("test/fixtures/files/placeholder.png")
  @ai_blob = ActiveStorage::Blob.create_and_upload!(
    io: File.open(image_path),
    filename: "ai-placeholder.png",
    content_type: "image/png"
  )
end

When("I request an AI description") do
  signed_id = @ai_blob&.signed_id
  page.driver.post(generate_description_listings_path, params: { signed_id: signed_id })
  @ai_response = JSON.parse(page.body)
  @ai_status = page.status_code
end

When("I request an AI description without providing an image") do
  page.driver.post(generate_description_listings_path, params: {})
  @ai_response = JSON.parse(page.body)
  @ai_status = page.status_code
end

Given("the AI description feature is disabled") do
  override_config(:ai_description_enabled, false)
end

Given("the AI description rate limit is set to {int}") do |limit|
  override_config(:ai_description_rate_limit, limit)
end

Then("the AI description response should include a description and category") do
  expect(@ai_status).to eq(200)
  expect(@ai_response["description"]).to be_a(String)
  expect(@ai_response["description"].strip).not_to be_empty
  expect(@ai_response["category"]).to be_a(String)
  expect(@ai_response["category"].strip).not_to be_empty
end

Then("the AI response contains error {string}") do |message|
  expect(@ai_response["error"]).to include(message)
end
