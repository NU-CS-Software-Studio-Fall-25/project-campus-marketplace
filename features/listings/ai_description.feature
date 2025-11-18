@stub_ai_description
Feature: AI-generated listing descriptions
  The backend can generate descriptions from uploaded listing images

  Background:
    Given I am a confirmed user
    And I am signed in
    And I have uploaded an image for AI description

  Scenario: Generate a description when the feature is enabled
    When I request an AI description
    Then the AI description response should include a description and category

  Scenario: Error when no image is provided
    When I request an AI description without providing an image
    Then the AI response contains error "No image provided"
