World(RSpec::Matchers)

Given("I am on the sign up page") do
  visit new_user_path
end

When("I register with a valid Northwestern email") do
  attrs = build_user_attributes

  visit new_user_path
  fill_in "First name", with: attrs[:first_name]
  fill_in "Last name", with: attrs[:last_name]
  fill_in "Northwestern email", with: attrs[:email_address]
  fill_in "Username", with: attrs[:username]
  fill_in "Phone number (optional)", with: ""
  fill_in "Password", with: attrs[:password]
  fill_in "Password confirmation", with: attrs[:password_confirmation]
  click_button "Create Account"

  @current_user = User.find_by(email_address: attrs[:email_address])
  @current_password = attrs[:password]
end

When("I try to register with email {string}") do |email|
  attrs = build_user_attributes(email_address: email, username: "user#{unique_suffix}")

  visit new_user_path
  fill_in "First name", with: attrs[:first_name]
  fill_in "Last name", with: attrs[:last_name]
  fill_in "Northwestern email", with: attrs[:email_address]
  fill_in "Username", with: attrs[:username]
  fill_in "Password", with: attrs[:password]
  fill_in "Password confirmation", with: attrs[:password_confirmation]
  click_button "Create Account"
end

Given("I have an unconfirmed account") do
  create_unconfirmed_user
end

Given("I am on the sign in page") do
  visit new_session_path
end

When("I sign in with my credentials") do
  raise "Current user not set" unless @current_user.present? && @current_password.present?

  visit new_session_path
  fill_in "email_address", with: @current_user.email_address
  fill_in "password", with: @current_password
  click_button "Sign in"
end

When("I sign in with email {string} and password {string}") do |email, password|
  visit new_session_path
  fill_in "email_address", with: email
  fill_in "password", with: password
  click_button "Sign in"
end

Then("I should be signed in") do
  expect(page).to have_selector(:link_or_button, "Sign out")
end

Then("I should be asked to confirm my email") do
  expect(page).to have_content("Please confirm your email address")
end

Given("I have a confirmation token") do
  raise "Current user not set" unless @current_user.present?

  @confirmation_token = @current_user.generate_confirmation_token!
end

When("I visit the confirmation link") do
  raise "Confirmation token not set" unless @confirmation_token.present?

  visit confirmation_token_path(@confirmation_token, email: @current_user.email_address)
end

When("I visit the confirmation link with token {string}") do |token|
  visit confirmation_token_path(token, email: @current_user.email_address)
end

Then("my account should be confirmed") do
  expect(@current_user.reload.confirmed?).to be(true)
end

Given("I have a password reset token") do
  raise "Current user not set" unless @current_user.present?

  @reset_token = @current_user.generate_password_reset!
end

Given("I have an expired password reset token") do
  step("I have a password reset token")
  @current_user.update_columns(reset_password_sent_at: 2.hours.ago)
end

When("I request a password reset for my account") do
  visit new_password_path
  fill_in "Email address", with: @current_user.email_address
  click_button "Email reset instructions"
end

When("I visit the password reset page from the email") do
  raise "Reset token not set" unless @reset_token.present?

  visit edit_password_path(@reset_token, email: @current_user.email_address)
end

When("I choose a new password {string}") do |password|
  fill_in "New password", with: password
  fill_in "Confirm new password", with: password
  click_button "Save new password"
end
