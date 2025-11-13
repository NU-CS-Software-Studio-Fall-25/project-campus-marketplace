Feature: Manage listings
  To validate the marketplace listings flow end-to-end
  Logged-in students should be able to publish a listing

  Background:
    Given I am a confirmed user
    And I am signed in

  Scenario: User creates a new listing
    When I create a listing with the following details:
      | Title       | Vintage Calculator |
      | Description | Carefully used TI-84 calculator with fresh batteries. |
      | Price       | 25.00 |
    Then I should see "Listing was successfully created."
    And I should see "Vintage Calculator"
    And I should see "Carefully used TI-84 calculator with fresh batteries."
