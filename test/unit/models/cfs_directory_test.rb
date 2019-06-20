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
    assert_equal [child_dirs, grandchild_dirs].flatten.to_set, parent_dir.directories_in_tree(include_self: false).to_set

    relative_dirs = [aunt_dir, cousin_dirs].flatten.to_set
    aunt_dir.each_directory_in_tree do |dir|
      relative_dirs.delete(dir)
    end
    assert_equal [].to_set, relative_dirs
  end

  test 'root cfs directories may not have the same path' do
    FactoryBot.create(:attached_cfs_directory, path: '1/2')
    other_file_group = FactoryBot.create(:bit_level_file_group)
    bad_root_directory =  FactoryBot.build(:cfs_directory, parent: other_file_group, path: '1/2')
    refute bad_root_directory.valid?
    assert_equal 1, bad_root_directory.errors.size
    assert_includes bad_root_directory.errors.full_messages, 'Path must be unique for roots'
  end

  test 'create file with specified components' do
    directory = FactoryBot.create(:attached_cfs_directory, path: '1/2')
    directory.send(:ensure_file_with_directory_components, 'file.txt', ['.', 'subdir', 'path'])
    created_file = CfsFile.find_by(name: 'file.txt')
    assert created_file
    assert_equal 'path', created_file.cfs_directory.path
    assert_equal 'subdir', created_file.cfs_directory.parent.path
    assert_equal directory, created_file.cfs_directory.parent.parent
  end

  test 'create directory with specified components' do
    directory = FactoryBot.create(:attached_cfs_directory, path: '1/2')
    directory.send(:ensure_directory_with_directory_components, ['.', 'subdir', 'path'])
    created_directory = CfsDirectory.find_by(path: 'path')
    assert created_directory
    assert_equal 'subdir', created_directory.parent.path
    assert_equal directory, created_directory.parent.parent
  end

  private

  def create_child(parent)
    FactoryBot.create(:cfs_directory, parent: parent, root_cfs_directory: parent.root_cfs_directory)
  end

end