# Created by mfall3 at 7/14/22
Feature: Main Storage
  # In order to store files
  # As user of the systemd
  # I want to read and write binary objects

  Scenario: Write binary object
    Given the main storage has a key 'dogs/intro.txt' with contents 'anything'
    Then the main storage should have a key 'dogs/intro.txt' with contents 'anything'