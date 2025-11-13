Feature: Manage listings
  To validate the marketplace listings flow end-to-end
  Logged-in students should be able to delete a listing they previously published

  Background:
    Given I am a confirmed user
    And I am signed in

Scenario: User deletes one of their listings
  Given I have created a listing with the following details:
    | Title       | Vintage Calculator |
    | Description | Carefully used TI-84 calculator with fresh batteries. |
    | Price       | 25.00 |
  Then I should see a button to delete the listing on the all listings page
  When I click the delete button for that listing
  Then I should see "Listing was successfully destroyed."
