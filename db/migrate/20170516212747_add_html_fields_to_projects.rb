class AddHtmlFieldsToProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :summary_html, :text
    add_column :projects, :specifications_html, :text
    #populate these new fields
    Project.find_each do |project|
      project.specifications = project.specifications
      project.summary = project.summary
      project.save!
    end
  end
end
