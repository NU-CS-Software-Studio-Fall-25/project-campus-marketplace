World(RSpec::Matchers)

Given("there is a listing available for bids") do
  seller = create_untracked_user
  @listing = create_listing_for(seller, title: "Campus Chair", price: 45.00)
end

Given("there is a pending bid on that listing from another user") do
  raise "Listing not set" unless @listing.present?

  buyer = create_untracked_user(username: "buyer#{unique_suffix}")
  @bid = @listing.bids.create!(buyer:, amount: 20.00, message: "Ready to pick up")
end

Given("I have a personal listing") do
  @listing = create_listing_for(@current_user, title: "My Dorm Couch", price: 80.00)
end

When("I visit that listing") do
  visit listing_path(@listing)
end

When("I submit a bid of {string} with message {string}") do |amount, message|
  fill_in "Your offer", with: amount
  fill_in "Message (optional)", with: message
  click_button "Send offer"
end

When("I attempt to bid on my own listing") do
  page.driver.post(listing_bids_path(@listing), { bid: { amount: 10, message: "" } })
  visit listing_path(@listing)
end

Given("I sign in as the seller for that listing") do
  raise "Listing not set" unless @listing.present?

  @current_user = @listing.user
  @current_password = default_password
  visit new_session_path
  fill_in "email_address", with: @current_user.email_address
  fill_in "password", with: @current_password
  click_button "Sign in"
end

When("I accept the bid") do
  visit listing_path(@listing)
  click_button "Accept", exact: true
end

When("I counter the bid without an amount") do
  visit listing_path(@listing)
  form = find(:css, "form[action='#{counter_bid_path(@bid)}']")
  form.fill_in "bid[response_amount]", with: ""
  form.fill_in "bid[response_message]", with: "Need higher"
  form.click_button "Counter"
end

When("I counter the bid with amount {string} and message {string}") do |amount, message|
  visit listing_path(@listing)
  form = find(:css, "form[action='#{counter_bid_path(@bid)}']")
  form.fill_in "bid[response_amount]", with: amount
  form.fill_in "bid[response_message]", with: message
  form.click_button "Counter"
end

Then("a bid notification email should be queued to the seller") do
  job = ActiveJob::Base.queue_adapter.enqueued_jobs.find do |j|
    j[:job] == ActionMailer::MailDeliveryJob &&
      j[:args].second == "new_bid_notification"
  end
  expect(job).to be_present
end

Then("a bid response email should be queued to the buyer") do
  job = ActiveJob::Base.queue_adapter.enqueued_jobs.find do |j|
    j[:job] == ActionMailer::MailDeliveryJob &&
      j[:args].second == "bid_response_notification"
  end
  expect(job).to be_present
end
