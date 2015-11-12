class FileFormatTestDecorator < BaseDecorator

  delegate :file_group, :collection, :repository, to: :cfs_file
  [:file_group, :collection, :repository].each do |ancestor|
    delegate :id, :title, to: ancestor, prefix: true
  end
  delegate :acquisition_method, to: :file_group

end
