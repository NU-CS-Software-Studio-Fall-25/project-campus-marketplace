Feature: Password reset
  Users can reset their password securely when they forget it

  Background:
    Given I am a confirmed user

  Scenario: Request and complete a password reset with a valid token
    And I have a password reset token
    When I visit the password reset page from the email
    And I choose a new password "BetterPass!2"
    Then I should see "Your password has been updated and you're signed in."

  Scenario: Visiting with an expired token is rejected
    And I have an expired password reset token
    When I visit the password reset page from the email
    Then I should see "Password reset link is invalid or has expired."
