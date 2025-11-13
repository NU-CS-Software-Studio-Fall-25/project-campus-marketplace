Feature: Filter listings by category
  To help students find relevant items quickly
  The listings page should limit results to the selected categories

  Background:
    Given I am a confirmed user
    And I am signed in

  Scenario: User filters listings to a single category
    When I create a listing with the following details:
      | Title       | Vintage Calculator |
      | Description | Carefully used TI-84 calculator with fresh batteries. |
      | Price       | 25.00 |
      | Category    | Electronics |
    And I create a listing with the following details:
      | Title       | Cozy Reading Chair |
      | Description | Plush chair with storage pockets for books. |
      | Price       | 120.00 |
      | Category    | Furniture |
    When I filter listings by category "Furniture"
    Then I should see "Cozy Reading Chair"
    And I should not see "Vintage Calculator"
