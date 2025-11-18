World(ActionView::RecordIdentifier)
World(RSpec::Matchers)

Given("there is a listing from another user titled {string}") do |title|
  seller_suffix = unique_suffix
  seller_attrs = build_user_attributes(
    email_address: "seller#{seller_suffix}@u.northwestern.edu",
    username: "seller#{seller_suffix}"
  )
  seller = User.create!(seller_attrs)

  @listing = create_listing_for(
    seller,
    title: title,
    description: "Lightly used and available for pickup on campus."
  )
end

When("I like that listing") do
  visit listings_path
  within("##{dom_id(@listing)}") do
    click_link "Like"
  end
end

Given("I have liked the listing already") do
  step("I like that listing")
end

When("I unlike that listing") do
  visit listings_path
  within("##{dom_id(@listing)}") do
    click_link "Liked"
  end
end

When("I like that listing twice") do
  step("I like that listing")
  page.driver.post(favorites_path(listing_id: @listing.id))
end

Then("the listing appears in my likes") do
  visit favorites_path
  expect(page).to have_content(@listing.title)
end

Then("the listing should not appear in my likes") do
  visit favorites_path
  expect(page).not_to have_content(@listing.title)
end

Then("the listing should only appear once in my likes") do
  expect(Favorite.where(user: @current_user, listing: @listing).count).to eq(1)
  expect(@listing.reload.favorites_count).to eq(1)
end
