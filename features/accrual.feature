Feature: File accrual
  In order to add files to already existing file groups
  As a medusa admin
  I want to be able to browse staging and start jobs to copy files from staging to bit storage

  Background:
    When PENDING
    #I have a BLFG with no cfs directory attached
    #I have a BLFG with cfs directory attached with a couple of levels
    #I have some stuff in staging that can be ingested

  Scenario: There is no accrual button nor form on a file group without cfs directory
    When PENDING

  Scenario: There is an accrual button and form on a file group with cfs directory
    When PENDING

  Scenario: There is an accrual button and form on a cfs directory
    When PENDING

  Scenario: There is no accrual button nor form on a file group for a non medusa admin
    When PENDING

  Scenario: There is no accrual button nor form on a cfs directory for a non medusa admin
    When PENDING