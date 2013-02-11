class AddNameRiskAndTypeToAssessments < ActiveRecord::Migration
  def up
    add_column :assessments, :name, :string
    add_column :assessments, :assessment_type, :string
    add_column :assessments, :preservation_risk_level, :string
    Assessment.all.each do |assessment|
      assessment.assessment_type = 'external_files'
      assessment.preservation_risk_level = 'medium'
      assessment.name = assessment.date.to_s
      assessment.save!
    end
  end

  def down
    remove_column :assessments, :name, :assessment_type, :preservation_risk_level
  end
end
