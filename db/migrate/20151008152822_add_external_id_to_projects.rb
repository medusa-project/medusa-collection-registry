class AddExternalIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :external_id, :string, default: ''
    Project.find_each do |project|
      project.external_id ||= ''
      project.save!
    end
  end
end
