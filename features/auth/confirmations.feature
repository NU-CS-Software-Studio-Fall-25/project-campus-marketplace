Feature: Email confirmation
  To keep accounts verified
  Users must confirm their email before accessing the marketplace

  Background:
    Given I have an unconfirmed account

  Scenario: Valid confirmation link confirms the user
    And I have a confirmation token
    When I visit the confirmation link
    Then my account should be confirmed
    And I should see "Your email has been confirmed!"

  Scenario: Invalid token shows an error
    When I visit the confirmation link with token "bad-token"
    Then I should see "Confirmation link is invalid or has expired."
