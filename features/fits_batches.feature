@javascript
Feature: FITS batch processing
  As a librarian
  In order to learn about the files that we have
  I want to be able to run FITS on batches of files

  Background:
    Given I am logged in as an admin
    And the main storage has a key 'dogs/toy-dogs/joe.txt' with contents 'joe'
    And the main storage has a key 'dogs/toy-dogs/pete.txt' with contents 'pete'
    And the main storage has a key 'dogs/toy-dogs/bob.txt' with contents 'bob'
    And the main storage has a key 'dogs/toy-dogs/fred.xml' with contents '<?xml version="1.0"?><fred/>'
    And the collection with title 'Dogs' has child file groups with fields:
      | title   | type              |
      | Toys    | BitLevelFileGroup |
    And the file group titled 'Toys' has cfs root 'dogs/toy-dogs' and delayed jobs are run

  Scenario: Run batch of FITS on files by extension
    When I go to the dashboard
    And I click on 'File Statistics'
    And I click on 'txt'
    And I click on 'Run FITS batch'
    Then I should be on the cfs files page for the file extension with extension 'txt'
    And I should see 'FITS batch scheduled for extension 'txt''
    When delayed jobs are run
    Then 3 cfs files should have fits attached
    And delayed jobs are run
    And 'admin@example.com' should receive an email with subject 'Medusa: FITS batch completed'

  Scenario: Run batch of FITS on files by mime type
    When I go to the dashboard
    And I click on 'File Statistics'
    And I click on 'text/plain'
    And I click on 'Run FITS batch'
    Then I should be on the cfs files page for the content type with name 'text/plain'
    And I should see 'FITS batch scheduled for mime type 'text/plain''
    And delayed jobs are run
    Then 3 cfs files should have fits attached
    And 'admin@example.com' should receive an email with subject 'Medusa: FITS batch completed'

  @poltergeist
  Scenario: Only one delayed job may be active for an extension at a time
    When I go to the dashboard
    And I click on 'File Statistics'
    And I click on 'xml'
    And I click on 'Run FITS batch'
    And I go to the dashboard
    And I click on 'File Statistics'
    And I click on 'xml'
    And I click on 'Run FITS batch'
    Then I should see 'There is already a FITS batch scheduled for extension 'xml''

  Scenario: Only one delayed job may be active for an extension at a time
    When I go to the dashboard
    And I click on 'File Statistics'
    And I click on 'text/xml'
    And I click on 'Run FITS batch'
    And I go to the dashboard
    And I click on 'File Statistics'
    And I click on 'text/xml'
    And I click on 'Run FITS batch'
    Then I should see 'There is already a FITS batch scheduled for mime type 'text/xml''

  Scenario: Only admins may run FITS batch jobs by mime type
    When I relogin as a manager
    And I go to the dashboard
    And I click on 'File Statistics'
    And I click on 'text/xml'
    And I click on 'Run FITS batch'
    Then I should be unauthorized

  Scenario: Only admins may run FITS batch jobs by extension
    When I relogin as a manager
    And I go to the dashboard
    And I click on 'File Statistics'
    And I click on 'xml'
    And I click on 'Run FITS batch'
    Then I should be unauthorized
