require 'rails_helper'

RSpec.describe BitLevelFileGroup, type: :model do 
  describe 'associations' do 
    it { is_expected.to belong_to(:collection) }

    it { is_expected.to have_many(:job_cfs_initial_directory_assessments)
          .class_name('Job::CfsInitialDirectoryAssessment')
          .with_foreign_key(:file_group_id) }

    it { is_expected.to have_many(:archived_accrual_jobs)
          .dependent(:destroy)
          .with_foreign_key(:file_group_id) }
  end

  describe 'delegations' do 
    it { is_expected.to delegate_method(:ensure_file_at_relative_path).to(:cfs_directory) }
    it { is_expected.to delegate_method(:find_directory_at_relative_path).to(:cfs_directory) }
    it { is_expected.to delegate_method(:find_file_at_relative_path).to(:cfs_directory) }
  end

  describe 'callbacks' do
    it 'creates a CfsDirectory with the expected path after creation' do
      file_group = create(:bit_level_file_group, :with_cfs_directory)
      expected_path = "#{file_group.collection_id}/#{file_group.id}"
      expect(file_group.cfs_directory.path).to eq(expected_path)
    end
  
    context 'when the cfs_directory is not empty' do
      it 'does not destroy the cfs_directory' do
        file_group = create(:bit_level_file_group, :with_cfs_directory)

        create(
          :cfs_directory,
          parent: file_group.cfs_directory,
          parent_type: 'CfsDirectory',
          root_cfs_directory: file_group.cfs_directory
        )
    
        cfs_directory = file_group.cfs_directory
    
        expect(cfs_directory.is_empty?).to be false
        expect(CfsDirectory.exists?(cfs_directory.id)).to be true
    
        
        file_group.send(:maybe_destroy_cfs_directories)
    
        expect(CfsDirectory.exists?(cfs_directory.id)).to be true
      end
    end
    
    
    context 'when the cfs_directory is empty' do
      it 'destroys the cfs_directory' do
        file_group = create(:bit_level_file_group, :with_cfs_directory)
        cfs_directory = file_group.cfs_directory

        expect(cfs_directory.is_empty?).to be true
        expect(CfsDirectory.exists?(cfs_directory.id)).to be true

        # Bypass frozen proxy object error when desstroy is called on CFS directory
        allow(cfs_directory).to receive(:destroy) do
          CfsDirectory.where(id: cfs_directory.id).delete_all
        end
        
        file_group.send(:maybe_destroy_cfs_directories)

        expect(CfsDirectory.exists?(cfs_directory.id)).to be false
      end
    end
  end

  describe 'instance methods ' do 
    describe '#expected_relative_cfs_root_directory' do
      it 'returns path based on collection and id' do
        file_group = create(:bit_level_file_group)
        expect(file_group.expected_relative_cfs_root_directory).to eq("#{file_group.collection_id}/#{file_group.id}")
      end
    end

    describe '#schedule_initial_cfs_assessment' do
      it 'schedules the assessment job exactly once' do
        file_group = create(:bit_level_file_group)
        
        allow(Job::CfsInitialFileGroupAssessment).to receive(:create_for)

        file_group.schedule_initial_cfs_assessment

        expect(Job::CfsInitialFileGroupAssessment).to have_received(:create_for).with(file_group).once
      end
    end

    describe '#run_initial_cfs_assessment' do
      it 'triggers make_and_assess_tree on the directory' do
        file_group = create(:bit_level_file_group, :with_cfs_directory)
        expect(file_group.cfs_directory).to receive(:make_and_assess_tree)
        file_group.run_initial_cfs_assessment
      end
    end

    describe '#running_initial_assessments_file_count' do
      it 'returns sum of file counts from related directory assessments' do
        file_group = create(:bit_level_file_group)
        create(:cfs_initial_directory_assessment, file_group: file_group, file_count: 3)
        create(:cfs_initial_directory_assessment, file_group: file_group, file_count: 2)
        expect(file_group.running_initial_assessments_file_count).to eq(5)
      end
    end

    describe '#pristine?' do
      it 'returns true if no cfs_directory is set' do
        file_group = create(:bit_level_file_group)
        allow(file_group).to receive(:cfs_directory).and_return(nil)
        expect(file_group.pristine?).to be true
      end
    end

    describe '#file_size' do
      it 'returns total_file_size' do
        file_group = create(:bit_level_file_group, total_file_size: 123)
        expect(file_group.file_size).to eq(123)
      end
    end

    describe '#file_count' do
      it 'returns total_files' do
        file_group = create(:bit_level_file_group, total_files: 10)
        expect(file_group.file_count).to eq(10)
      end
    end

    describe '#is_currently_assessable?' do
      it 'returns false if a job exists' do
        file_group = create(:bit_level_file_group)
        create(:cfs_initial_directory_assessment, file_group: file_group)
        expect(file_group.is_currently_assessable?).to be false
      end
    end

    describe '#cfs_directory_id' do
      it 'returns the id of the associated cfs_directory' do
        file_group = create(:bit_level_file_group, :with_cfs_directory)
        expect(file_group.cfs_directory_id).to eq(file_group.cfs_directory.id)
      end
    end

    describe '#accrual_unstarted?' do
      it 'returns true if there are no events and it is pristine' do
        file_group = create(:bit_level_file_group)
        allow(file_group).to receive(:pristine?).and_return(true)
        allow(file_group).to receive_message_chain(:events, :where).and_return([])
    
        expect(file_group.accrual_unstarted?).to be true
      end
    end

    describe '#check_emptiness' do
      it 'prevents deletion when not pristine' do
        file_group = create(:bit_level_file_group)
        allow(file_group).to receive(:pristine?).and_return(false)
    
        result = file_group.send(:check_emptiness)
    
        expect(result).to be false
        expect(file_group.errors[:base]).to include(
          'This file group has content and cannot be deleted. Please contact Medusa administrators to have it removed.'
        )
      end

      it 'allows deletion when pristine' do
        file_group = create(:bit_level_file_group)
        allow(file_group).to receive(:pristine?).and_return(true)

        result = file_group.send(:check_emptiness)

        expect(result).to be true
        expect(file_group.errors[:base]).to be_empty
      end
    end
  end
end