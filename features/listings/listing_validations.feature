Feature: Listing validations and updates
  Sellers must provide complete information for their listings

  Background:
    Given I am a confirmed user
    And I am signed in

  Scenario: Listing creation fails without an image
    When I attempt to create a listing without an image
    Then I should see "Image must be attached"

  Scenario: Update a listing with new details
    Given I have created a listing with the following details:
      | Title       | Old Desk                |
      | Description | Wooden desk in good condition |
      | Price       | 50                      |
      | Category    | furniture               |
    When I update the listing title to "Refinished Desk" and price to "75"
    Then I should see "Listing was successfully updated."
