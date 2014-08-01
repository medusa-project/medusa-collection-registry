Feature: Authorization
  In order to control access to myself
  As the system
  I want to be able to check user's authorizations

  Background:
    Given There is a collection titled 'Dogs'

  Scenario: A visitor should not be able to view a restricted page
    Given I am logged in as a visitor
    When I edit the collection titled 'Dogs'
    Then I should be redirected to the unauthorized page
    And I should see 'You are not authorized to view the requested page.'

  Scenario: An admin should be able to view things
    Given I am logged in as an admin
    When I edit the collection titled 'Dogs'
    Then I should be on the edit page for the collection titled 'Dogs'