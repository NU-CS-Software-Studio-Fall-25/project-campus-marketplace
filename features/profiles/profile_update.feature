Feature: Update profile details
  Users can maintain accurate profile information to build trust

  Background:
    Given I am a confirmed user
    And I am signed in

  Scenario: Add or update phone number
    When I open my profile for editing
    And I update my phone number to "+18475550123"
    Then I should see "Profile updated."
    And I should see "+18475550123"

  Scenario: Clear an existing phone number
    Given my profile has phone number "8475550123"
    When I open my profile for editing
    And I remove my phone number
    Then I should see "Profile updated."
    And I should see "Not added yet"

  Scenario: Invalid phone number is rejected
    When I open my profile for editing
    And I update my phone number to "abc123"
    Then I should see "Phone number must be digits with optional leading +"
