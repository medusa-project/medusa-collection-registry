Feature: Bit file FITS XML
  In order to Assess file quality
  As a librarian
  I want to be able to generate and see the FITS metadata for a bit file

  Background:
    Given I am logged in as an admin
    And I have a directory named 'dog-files'
    And the directory named 'dog-files' has bit files with fields:
      | name    |
      | grass.jpg |

  Scenario: Bit File already has xml - there should be a link from the owning directory and I should be able to view XML
    Given the bit file named 'grass.jpg' has FITS xml attached
    When I view the directory named 'dog-files'
    And I click on 'View XML'
    Then I should be on the view page for the FITS XML for the bit file named 'grass.jpg'

  Scenario: Bit File does not already have xml - there should be a link to create and view it
    When I view the directory named 'dog-files'
    And I click on 'Create XML'
    Then I should be on the view page for the FITS XML for the bit file named 'grass.jpg'
    And the bit file named 'grass.jpg' should have FITS XML attached
