require 'rails_helper'

RSpec.describe Collection, type: :model do
  
  describe 'associations' do
    it { should belong_to(:repository) }
    it { should have_many(:assessments).dependent(:destroy) }
    it { should have_many(:file_groups).dependent(:destroy) }
    it { should have_one(:rights_declaration).dependent(:destroy) }
    it { should have_many(:attachments).dependent(:destroy) }
    it { should have_many(:projects) }
    it { should have_many(:child_collections) }
    it { should have_many(:parent_collections) }
  end

  describe 'validations' do 
    subject { build(:collection, repository: create(:repository)) }
    it 'is valid with valid attributes' do 
      expect(subject).to be_valid
    end
    
    it 'is invalid without a title' do
      subject.title = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:title]).to include("can't be blank")
    end

    it 'is invalid without a repository' do
      subject.repository = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:repository_id]).to include("can't be blank")
    end

    it 'is invalid with a duplicate title in the same repository' do
      create(:collection, title: subject.title, repository: subject.repository)
      expect(subject).not_to be_valid
      expect(subject.errors[:title]).to include("has already been taken")
    end

    it 'is valid with a duplicate title in a different repository' do
      other_repo = create(:repository)
      create(:collection, title: "Shared Title", repository: other_repo)

      subject.title = "Shared Title"
      subject.repository = create(:repository) 
      expect(subject).to be_valid
    end
  end

  describe 'callbacks' do 
    it 'ensures a rights declaration if none exists' do 
      collection = build(:collection, rights_declaration: nil)
      collection.valid?
      expect(collection.rights_declaration).to be_present
    end
  end

  describe 'scopes and class methods' do
    describe '.title_order' do
      it 'returns collections ordered by title ASC' do
        c1 = create(:collection, title: 'Zoo')
        c2 = create(:collection, title: 'Alpha')
        expect(Collection.title_order).to eq([c2, c1])
      end
    end
  end

  describe 'instance methods' do 
    it 'calculates total size of bit-level file groups' do 
      collection = create(:collection)
      file_group_1 = create(:bit_level_file_group, collection: collection)
      file_group_2 = create(:bit_level_file_group, collection: collection)

      file_group_1.update!(total_file_size: 100.0)
      file_group_2.update!(total_file_size: 200.0)
      
      expect(collection.total_size).to eq(300.0)
    end

    it 'sums total_files across bit-level file groups' do
      collection = create(:collection)
      create(:bit_level_file_group, collection: collection).update_column(:total_files, 5)
      create(:bit_level_file_group, collection: collection).update_column(:total_files, 7)

      expect(collection.total_files).to eq(12)
    end
    
    it 'returns both direct assessments and file group assessments' do
      collection = create(:collection)
      file_group = create(:bit_level_file_group, collection: collection)

      assessment1 = create(:assessment, assessable: collection)
      assessment2 = create(:assessment, assessable: file_group)

      expect(collection.recursive_assessments).to contain_exactly(assessment1, assessment2)
    end

    it 'returns IDs from non-empty CFS directories of bit-level file groups' do
      collection = create(:collection)
      file_group = create(:bit_level_file_group, collection: collection)
      #stub cfs directory as non empty and return sub directory Ids [101, 102]
      cfs_directory = instance_double('CfsDirectory', is_empty?: false, recursive_subdirectory_ids: [101, 102])
      allow_any_instance_of(BitLevelFileGroup).to receive(:cfs_directory).and_return(cfs_directory)

      expect(collection.timeline_directory_ids).to eq([101, 102])
    end

    it 'returns a valid HTTPS URL for the collection' do
      collection = create(:collection)
      expect(collection.medusa_url).to eq("https://medusa.library.illinois.edu/collections/#{collection.id}")
    end
  end
end