Feature: Assessment description
  In order to track information about assessments
  As a librarian
  I want to edit assessment information

  Background:
    And the repository titled 'Animals' has collections with fields:
      | title |
      | Dogs  |
    And the collection titled 'Dogs' has assessments with fields:
      | date       | preservation_risks                           | notes                                      | name      | assessment_type | preservation_risk_level |
      | 2012-01-09 | Old formats. http://preservation.example.com | Pictures of dogs. https://dogs.example.com | Once over | external_files  | medium                  |

  Scenario: View an assessment
    Given I am logged in as an admin
    When I view the assessment with date '2012-01-09' for the collection titled 'Dogs'
    Then I should see '2012-01-09'
    And I should see 'Old formats'
    And I should see 'Pictures of dogs'
    And I should see all of:
      | Once over | external_files | medium |

  Scenario: View an assessment as manager
    Given I am logged in as a manager
    When I view the assessment with date '2012-01-09' for the collection titled 'Dogs'
    Then I should be on the view page for the assessment with date '2012-01-09' for the collection titled 'Dogs'

  Scenario: View an assessment as visitor
    Given I am logged in as a visitor
    When I view the assessment with date '2012-01-09' for the collection titled 'Dogs'
    Then I should be on the view page for the assessment with date '2012-01-09' for the collection titled 'Dogs'

  Scenario: Edit an assessment
    Given I am logged in as an admin
    When I edit the assessment with date '2012-01-09' for the collection titled 'Dogs'
    And I fill in fields:
      | Notes | Images of canines |
    And I press 'Update Assessment'
    Then I should be on the view page for the assessment with date '2012-01-09' for the collection titled 'Dogs'
    And I should see 'Images of canines'
    And I should not see 'Pictures of dogs'

  Scenario: Edit an assessment as a manager
    Given I am logged in as a manager
    When I edit the assessment with date '2012-01-09' for the collection titled 'Dogs'
    And I fill in fields:
      | Notes | Images of canines |
    And I press 'Update Assessment'
    Then I should be on the view page for the assessment with date '2012-01-09' for the collection titled 'Dogs'
    And I should see 'Images of canines'
    And I should not see 'Pictures of dogs'

  Scenario: Navigate from the assessment view page to owning collection
    Given I am logged in as an admin
    When I view the assessment with date '2012-01-09' for the collection titled 'Dogs'
    And I click on 'Dogs'
    Then I should be on the view page for the collection titled 'Dogs'

  Scenario: Navigate from assessment view page to its edit page
    Given I am logged in as an admin
    When I view the assessment with date '2012-01-09' for the collection titled 'Dogs'
    And I click on 'Edit'
    Then I should be on the edit page for the assessment with date '2012-01-09' for the collection titled 'Dogs'

  Scenario: Delete assessment from view page
    Given I am logged in as an admin
    When I view the assessment with date '2012-01-09' for the collection titled 'Dogs'
    And I click on 'Delete'
    Then I should be on the view page for the collection titled 'Dogs'
    And The collection titled 'Dogs' should not have an assessment with date '2012-01-09'

  Scenario: Create a new assessment
    Given I am logged in as an admin
    When I view the collection titled 'Dogs'
    And I click on 'Add Assessment'
    And I fill in fields:
      | Preservation risks  | There are corrupt files too |
      | Notes               | I like dogs                 |
      | Date                | 2012-02-10                  |
      | Name                | Initial assessment          |
      | Naming conventions  | Random                      |
      | Directory structure | Unstructured                |
      | Last access date    | 2013-02-14                  |
      | File format         | Heterogeneous               |
      | Total file size     | 100                         |
      | Total files         | 50                          |
    And I select 'external_files' from 'Assessment type'
    And I select 'low' from 'Preservation risk level'
    And I select 'paper tape' from 'Storage medium'
    And I press 'Create Assessment'
    Then I should be on the view page for the assessment with date '2012-02-10' for the collection titled 'Dogs'
    And I should see all of:
      | I like dogs | Random | Unstructured | 2013-02-14 | Heterogeneous | 100 | 50 |
    And The collection titled 'Dogs' should have an assessment with date '2012-02-10'

  Scenario: Create a new assessment as a manager
    Given I am logged in as a manager
    When I view the collection titled 'Dogs'
    And I click on 'Add Assessment'
    And I fill in fields:
      | Preservation risks  | There are corrupt files too |
      | Notes               | I like dogs                 |
      | Date                | 2012-02-10                  |
      | Name                | Initial assessment          |
      | Naming conventions  | Random                      |
      | Directory structure | Unstructured                |
      | Last access date    | 2013-02-14                  |
      | File format         | Heterogeneous               |
      | Total file size     | 100                         |
      | Total files         | 50                          |
    And I select 'external_files' from 'Assessment type'
    And I select 'low' from 'Preservation risk level'
    And I select 'paper tape' from 'Storage medium'
    And I press 'Create Assessment'
    Then I should be on the view page for the assessment with date '2012-02-10' for the collection titled 'Dogs'
    And I should see all of:
      | I like dogs | Random | Unstructured | 2013-02-14 | Heterogeneous | 100 | 50 |
    And The collection titled 'Dogs' should have an assessment with date '2012-02-10'

  Scenario: Autofill user id for new assessment
    Given I am logged in as an admin
    When I view the collection titled 'Dogs'
    And I click on 'Add Assessment'
    Then The field 'Author Net ID' should be filled in with 'admin'

  Scenario: Associate author with assessment
    Given I am logged in as an admin
    When I edit the assessment with date '2012-01-09' for the collection titled 'Dogs'
    And I fill in fields:
      | Author Net ID | wingram2 |
    And I press 'Update Assessment'
    Then I should see 'wingram2'
    And There should be a person with net ID 'wingram2'

  Scenario: Auto link links from notes and preservation risks
    Given I am logged in as an admin
    When I view the assessment with date '2012-01-09' for the collection titled 'Dogs'
    Then I should see a link to 'http://preservation.example.com'
    And I should see a link to 'https://dogs.example.com'

  Scenario: Name is required field
    Given I am logged in as an admin
    When I edit the assessment with date '2012-01-09' for the collection titled 'Dogs'
    And I fill in fields:
      | Name |  |
    And I press 'Update Assessment'
    Then I should see 'can't be blank'
