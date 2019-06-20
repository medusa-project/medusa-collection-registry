require 'test_helper'

class CfsFileTest < ActiveSupport::TestCase

  test 'cfs file knows its ancestors' do
    root_directory = FactoryBot.create(:attached_cfs_directory)
    child_directory = FactoryBot.create(:cfs_directory, parent: root_directory, root_cfs_directory: root_directory)
    cfs_file = FactoryBot.create(:cfs_file, cfs_directory: child_directory)
    assert_equal [root_directory, child_directory].to_set, cfs_file.ancestors.to_set
  end

  test 'CfsFile can make sure all file extensions are present' do
    extensions = ['txt', 'gif', 'lisp']
    extensions.each do |extension|
      cfs_file = FactoryBot.create(:cfs_file, name: "file.#{extension}")
      file_extension = cfs_file.file_extension
      cfs_file.update_column(:file_extension_id, nil)
      file_extension.destroy!
    end
    CfsFile.ensure_all_file_extensions
    extensions.each {|extension| assert FileExtension.find_by(extension: extension)}
  end

  test 'cfs file updates fixity status to ok' do
    [nil, '254e6fa26f5fce3ef58bdc3358d06886'].each do |md5_sum|
      cfs_file = FactoryBot.create(:cfs_file, md5_sum: md5_sum)
      cfs_file.stubs('exists_on_storage?': true, storage_md5_sum: '254e6fa26f5fce3ef58bdc3358d06886')
      assert_difference -> {cfs_file.fixity_check_results.where(status: :ok).count}, 1 do
        cfs_file.update_fixity_status_with_event
      end
      assert_equal 'ok', cfs_file.fixity_check_status
    end
  end

  test 'cfs file update fixity status to bad' do
    cfs_file = FactoryBot.create(:cfs_file, md5_sum: '123456a26f5fce3ef58bdc3358d06886')
    cfs_file.stubs(:storage_md5_sum).returns('254e6fa26f5fce3ef58bdc3358d06886')
    cfs_file.stubs(:exists_on_storage? => true)
    assert_difference -> {cfs_file.fixity_check_results.where(status: :bad).count} => 1,
                      -> {cfs_file.events.count} => 1,
                      -> {cfs_file.red_flags.count} => 1 do
      cfs_file.update_fixity_status_with_event
    end
    assert_equal 'bad', cfs_file.fixity_check_status
  end

  test 'cfs file update fixity status when not found' do
    cfs_file = FactoryBot.create(:cfs_file)
    assert_difference -> {cfs_file.fixity_check_results.where(status: :not_found).count} => 1,
                      -> {cfs_file.events.count} => 1,
                      -> {cfs_file.red_flags.count} => 1 do
      cfs_file.update_fixity_status_with_event
    end
    assert_equal 'nf', cfs_file.fixity_check_status
  end

end