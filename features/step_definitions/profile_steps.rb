World(RSpec::Matchers)

When("I open my profile for editing") do
  visit profile_path(edit: 1)
end

When("I update my phone number to {string}") do |phone_number|
  fill_in "Phone number", with: phone_number
  click_button "Save changes"
end

Given("my profile has phone number {string}") do |phone_number|
  @current_user.update!(phone_number: phone_number)
end

When("I remove my phone number") do
  fill_in "Phone number", with: ""
  click_button "Save changes"
end
