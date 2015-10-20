Feature: Assessment description
  In order to track information about assessments
  As a librarian
  I want to edit assessment information

  Background:
    And the repository with title 'Animals' has child collections with fields:
      | title |
      | Dogs  |
    And the assessable collection with title 'Dogs' has assessments with fields:
      | date       | preservation_risks                           | notes                                      | name      | assessment_type | preservation_risk_level |
      | 2012-01-09 | Old formats. http://preservation.example.com | Pictures of dogs. https://dogs.example.com | Once over | external_files  | medium                  |

  Scenario: View an assessment
    Given I am logged in as an admin
    When I view the assessment with date '2012-01-09'
    Then I should see '2012-01-09'
    And I should see 'Old formats'
    And I should see 'Pictures of dogs'
    And I should see all of:
      | Once over | external_files | medium |

  Scenario Outline: View an assessment
    Given I am logged in as a <user_type>
    When I view the assessment with date '2012-01-09'
    Then I should be on the view page for the assessment with date '2012-01-09'

    Examples:
      | user_type |
      | manager   |
      | visitor   |

  Scenario Outline: Edit an assessment
    Given I am logged in as a <user_type>
    When I edit the assessment with date '2012-01-09'
    And I fill in fields:
      | Notes | Images of canines |
    And I press 'Update'
    Then I should be on the view page for the assessment with date '2012-01-09'
    And I should see 'Images of canines'
    And I should not see 'Pictures of dogs'

    Examples:
      | user_type |
      | admin     |
      | manager   |

  Scenario: Navigate from the assessment view page to owning collection
    Given I am logged in as an admin
    When I view the assessment with date '2012-01-09'
    And I click on 'Dogs'
    Then I should be on the view page for the collection with title 'Dogs'

  Scenario: Navigate from assessment view page to its edit page
    Given I am logged in as an admin
    When I view the assessment with date '2012-01-09'
    And I click on 'Edit'
    Then I should be on the edit page for the assessment with date '2012-01-09'

  Scenario: Delete assessment from view page
    Given I am logged in as an admin
    When I view the assessment with date '2012-01-09'
    And I click on 'Delete'
    Then I should be on the view page for the collection with title 'Dogs'
    And The collection titled 'Dogs' should not have an assessment with date '2012-01-09'

  Scenario Outline: Create a new assessment
    Given I am logged in as an <user_type>
    When I view the collection with title 'Dogs'
    And I click on 'Assessments'
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
    And I press 'Create'
    Then I should be on the view page for the assessment with date '2012-02-10'
    And I should see all of:
      | I like dogs | Random | Unstructured | 2013-02-14 | Heterogeneous | 100 | 50 |
    And The collection titled 'Dogs' should have an assessment with date '2012-02-10'

    Examples:
      | user_type |
      | admin     |
      | manager   |

  Scenario: Autofill user id for new assessment
    Given I am logged in as an admin
    When I view the collection with title 'Dogs'
    And I click on 'Assessments'
    And I click on 'Add Assessment'
    Then The field 'Author Email' should be filled in with 'admin@example.com'

  Scenario: Associate author with assessment
    Given I am logged in as an admin
    When I edit the assessment with date '2012-01-09'
    And I fill in fields:
      | Author Email | wingram2@example.com |
    And I press 'Update'
    Then I should see 'wingram2@example.com'
    And a person with email 'wingram2@example.com' should exist

  Scenario: Auto link links from notes and preservation risks
    Given I am logged in as an admin
    When I view the assessment with date '2012-01-09'
    Then I should see a link to 'http://preservation.example.com'
    And I should see a link to 'https://dogs.example.com'

  Scenario: Name is required field
    Given I am logged in as an admin
    When I edit the assessment with date '2012-01-09'
    And I fill in fields:
      | Name |  |
    And I press 'Update'
    Then I should see 'can't be blank'
