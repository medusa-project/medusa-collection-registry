Feature: Ingest IDB file
  In order to preserve IDB files
  As IDB
  I want to be able to tell Medusa to ingest a file and have it go to preservation storage

  Scenario: Medusa receives message from IDB and creates delayed job to ingest
    When PENDING

  Scenario: Medusa runs delayed job for IDB ingest, ingesting file and returning message to IDB
    When PENDING