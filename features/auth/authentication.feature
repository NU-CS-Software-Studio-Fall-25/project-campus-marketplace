Feature: User authentication
  As a Northwestern student
  I want to register and sign in
  So I can manage my listings securely

  Scenario: Sign up with a Northwestern email
    When I register with a valid Northwestern email
    Then I should see "Check your email to confirm your account before signing in."

  Scenario: Reject non-Northwestern email at signup
    When I try to register with email "student@example.com"
    Then I should see "must end with northwestern.edu or u.northwestern.edu"

  Scenario: Confirmed user signs in successfully
    Given I am a confirmed user
    When I sign in with my credentials
    Then I should be signed in

  Scenario: Unconfirmed user is asked to confirm their email
    Given I have an unconfirmed account
    When I sign in with my credentials
    Then I should be asked to confirm my email
