require 'test_helper'

class ContentTypeTest < ActiveSupport::TestCase

  test 'content type associations and validations' do
    @subject = FactoryBot.create(:content_type)
    must validate_uniqueness_of(:name)
    must validate_numericality_of(:cfs_file_count)
    must validate_numericality_of(:cfs_file_size)
    must have_many(:cfs_files)
    must have_many(:file_format_profiles_content_types_joins).dependent(:destroy)
    must have_many(:file_format_profiles).through(:file_format_profiles_content_types_joins)
  end

  test 'empty content types can be pruned' do
    ['application/octet-stream', 'text/html', 'audio/mpeg3'].each {|name| FactoryBot.create(:content_type, name: name)}
    assert_equal 3, ContentType.count
    ContentType.find_by(name: 'text/html').cfs_files << FactoryBot.create(:cfs_file)
    ContentType.prune_empty
    assert_equal 1, ContentType.count
    assert ContentType.find_by(name: 'text/html')
  end

end