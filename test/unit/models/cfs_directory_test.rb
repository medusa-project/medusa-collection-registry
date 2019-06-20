require 'test_helper'

class CfsDirectoryTest < ActiveSupport::TestCase

  #Since the setup is a bit involved we use it to test a few things
  test 'subdirectory trees are computable and useable in a variety of ways' do
    root_directory = FactoryBot.create(:attached_cfs_directory)
    parent_dir, aunt_dir = 2.times.collect {create_child(root_directory)}
    child_dirs = 3.times.collect {create_child(parent_dir)}
    cousin_dirs = 3.times.collect {create_child(aunt_dir)}
    grandchild_dirs = child_dirs.collect {|child_dir| 2.times.collect {create_child(child_dir)}}.flatten


    parent_tree = [parent_dir, child_dirs, grandchild_dirs].flatten
    expected_ids = parent_tree.collect(&:id).sort
    assert_equal expected_ids, parent_dir.recursive_subdirectory_ids.sort

    assert_equal parent_tree.to_set, parent_dir.directories_in_tree.to_set
    assert_equal [child_dirs, grandchild_dirs].flatten.to_set, parent_dir.directories_in_tree(false).to_set

    relative_dirs = [aunt_dir, cousin_dirs].flatten.to_set
    aunt_dir.each_directory_in_tree do |dir|
      relative_dirs.delete(dir)
    end
    assert_equal [].to_set, relative_dirs
  end

  def create_child(parent)
    FactoryBot.create(:cfs_directory, parent: parent, root_cfs_directory: parent.root_cfs_directory)
  end

end