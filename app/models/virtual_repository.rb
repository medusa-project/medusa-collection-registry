class VirtualRepository < ActiveRecord::Base
  include Breadcrumb

  belongs_to :repository
  has_many :collection_virtual_repository_joins, dependent: :destroy
  has_many :collections, through: :collection_virtual_repository_joins

  breadcrumbs parent: :repository, label: :title

  def total_size
    self.collections.collect { |c| c.total_size }.sum
  end

  def total_files
    self.collections.collect {|c| c.total_files}.sum
  end

end
