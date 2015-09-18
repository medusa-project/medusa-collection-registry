Feature: Touching associated models
  In order to facilitate caching
  As the system
  I want to update timestamps for related models when updating a model

  Scenario: Simple association touches
    When I touch a model the associated model's timestamp is updated for:
      | cfs_file                              | file_extension, content_type, cfs_directory |
      | access_system_collection_join         | access_system, collection                   |
      | amazon_backup                         | cfs_directory, user                         |
      | assessment                            | storage_medium                              |
      | collection                            | repository, preservation_priority           |
      | file_group                            | collection, producer, package_profile       |
      | repository                            | institution                                 |
      | resource_typeable_resource_type_join  | resource_type                               |
      | virus_scan                            | file_group                                  |
      | job_cfs_directory_export              | user, cfs_directory                         |
      | job_cfs_initial_file_group_assessment | file_group                                  |
      | job_fits_directory                    | file_group, cfs_directory                   |
      | job_fits_directory_tree               | file_group, cfs_directory                   |
      | job_ingest_staging_delete             | user                                        |
      | job_virus_scan                        | file_group                                  |
      | workflow_accrual_job                  | cfs_directory, user, amazon_backup          |
      | workflow_ingest                       | user, amazon_backup                         |