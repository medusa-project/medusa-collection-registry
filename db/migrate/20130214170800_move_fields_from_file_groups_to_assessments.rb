class MoveFieldsFromFileGroupsToAssessments < ActiveRecord::Migration
  def up
    #add assessment fields
    add_column :assessments, :naming_conventions, :text
    add_column :assessments, :naming_conventions_html, :text
    add_column :assessments, :storage_medium_id, :integer, :index => true
    add_column :assessments, :directory_structure, :text
    add_column :assessments, :directory_structure_html, :text
    add_column :assessments, :last_access_date, :date
    add_column :assessments, :file_format, :string
    add_column :assessments, :total_file_size, :decimal
    add_column :assessments, :total_files, :integer
    #migrate values from each file group to assessment
    FileGroup.all.each do |file_group|
      assessment = Assessment.new(:name => "File Group #{file_group.id} migration",
                                  :assessment_type => 'external_files',
                                  :preservation_risk_level => 'medium',
                                  :naming_conventions => file_group.naming_conventions,
                                  :storage_medium_id => file_group.storage_medium_id,
                                  :directory_structure => file_group.directory_structure,
                                  :last_access_date => file_group.last_access_date,
                                  :file_format => file_group.file_format,
                                  :total_file_size => file_group.total_file_size,
                                  :total_files => file_group.total_files)
      assessment.assessable = file_group
      assessment.naming_conventions_html = file_group.naming_conventions_html
      assessment.directory_structure_html = file_group.directory_structure_html
      assessment.save!
    end
    #remove file group fields
    remove_column :file_groups, :naming_conventions, :naming_conventions_html, :storage_medium_id,
                  :directory_structure, :directory_structure_html, :last_access_date
  end

  #there's no way to completely reverse this, but we can do the db structure
  def down
    add_column :file_groups, :naming_conventions, :text
    add_column :file_groups, :naming_conventions_html, :text
    add_column :file_groups, :storage_medium_id, :integer, :index => true
    add_column :file_groups, :directory_structure, :text
    add_column :file_groups, :directory_structure_html, :text
    add_column :file_groups, :last_access_date, :date
    remove_column :assessments, :naming_conventions, :naming_conventions_html, :storage_medium_id,
                      :directory_structure, :directory_structure_html, :last_access_date,
                      :file_format, :total_file_size, :total_files
  end
end
