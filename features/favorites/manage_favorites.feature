Feature: Manage favorites
  Users can like and unlike listings to keep track of items they want

  Background:
    Given I am a confirmed user
    And I am signed in
    And there is a listing from another user titled "Vintage Lamp"

  Scenario: Save a listing to favorites
    When I like that listing
    Then I should see "Saved to likes."
    And the listing appears in my likes

  Scenario: Remove a listing from favorites
    Given I have liked the listing already
    When I unlike that listing
    Then I should see "Removed from likes."
    And the listing should not appear in my likes

  Scenario: Liking the same listing twice does not duplicate it
    When I like that listing twice
    Then the listing should only appear once in my likes
