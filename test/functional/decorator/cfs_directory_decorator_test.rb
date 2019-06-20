require 'test_helper'

class CfsDirectoryDecoratorTest < ActionDispatch::IntegrationTest

  test 'decorated cfs directory can generate file group and collection search paths' do
    file_group = FactoryBot.create(:bit_level_file_group)
    collection = file_group.collection
    decorated_cfs_directory = FactoryBot.create(:cfs_directory, parent: file_group).decorate
    assert_equal %Q(<a href="#{file_group_path(file_group)}">#{file_group.title}</a>), decorated_cfs_directory.search_file_group_link
    assert_equal %Q(<a href="#{collection_path(collection)}">#{collection.title}</a>),
                 decorated_cfs_directory.search_collection_link
  end

end