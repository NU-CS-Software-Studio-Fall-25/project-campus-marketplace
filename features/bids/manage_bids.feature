Feature: Manage bids
  Buyers can submit bids and sellers can respond with accept, reject, or counter while emails are queued

  Background:
    Given I am a confirmed user

  Scenario: Buyer submits a valid bid
    And there is a listing available for bids
    And I am signed in
    When I visit that listing
    And I submit a bid of "20.00" with message "Is pickup okay?"
    Then I should see "Your offer was sent to the seller."
    And a bid notification email should be queued to the seller

  Scenario: Buyer submits an invalid bid amount
    And there is a listing available for bids
    And I am signed in
    When I visit that listing
    And I submit a bid of "0" with message ""
    Then I should see "Amount must be greater than 0"

  Scenario: Seller cannot bid on their own listing
    And I have a personal listing
    And I am signed in
    When I attempt to bid on my own listing
    Then I should see "You cannot bid on your own listing."

  Scenario: Seller accepts a bid and emails the buyer
    And there is a listing available for bids
    And there is a pending bid on that listing from another user
    And I sign in as the seller for that listing
    When I accept the bid
    Then I should see "You accepted the offer."
    And a bid response email should be queued to the buyer

  Scenario: Seller counters with missing amount
    And there is a listing available for bids
    And there is a pending bid on that listing from another user
    And I sign in as the seller for that listing
    When I counter the bid without an amount
    Then I should see "Enter a counter offer amount."

  Scenario: Seller counters with a new amount
    And there is a listing available for bids
    And there is a pending bid on that listing from another user
    And I sign in as the seller for that listing
    When I counter the bid with amount "30.50" and message "Can you meet here?"
    Then I should see "Counter offer sent."
    And a bid response email should be queued to the buyer
