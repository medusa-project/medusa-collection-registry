require 'rails_helper'

RSpec.describe CfsDirectory, type: :model do
  describe 'validations' do
    context 'basic validations' do
      it 'is valid with a path and root_cfs_directory set for non-root directory' do
        parent = FactoryBot.create(:cfs_directory, :with_parent_file_group)
        parent.update!(root_cfs_directory: parent)

        dir = FactoryBot.create(:cfs_directory,
                                :with_parent_directory,
                                parent: parent,
                                root_cfs_directory: parent.root_cfs_directory)

        expect(dir).to be_valid
      end

      it 'is valid for a root directory with itself as root_cfs_directory' do
        dir = FactoryBot.create(:cfs_directory, :with_parent_file_group)
        dir.update!(root_cfs_directory: dir)
        expect(dir).to be_valid
      end
    end

    context 'subdirectory path uniqueness in scope of a parent' do
      let!(:parent_one) { create(:cfs_directory, :with_parent_file_group) }
      let!(:parent_two) { create(:cfs_directory, :with_parent_file_group) }

      let!(:existing_subdir) do
        create(:cfs_directory,
               :with_parent_directory,
               parent: parent_one,
               path: 'shared_name',
               root_cfs_directory: parent_one)
      end

      before do
        parent_one.update!(root_cfs_directory: parent_one)
        parent_two.update!(root_cfs_directory: parent_two)
      end

      it 'is invalid if another subdirectory has the same path under the same parent' do
        dup = build(:cfs_directory,
                    :with_parent_directory,
                    parent: parent_one,
                    path: 'shared_name',
                    root_cfs_directory: parent_one)
        expect(dup).not_to be_valid
        expect(dup.errors[:path]).to include('has already been taken')
      end

      it 'is valid if another subdirectory has the same path under a different parent' do
        dup = build(:cfs_directory,
                    :with_parent_directory,
                    parent: parent_two,
                    path: 'shared_name',
                    root_cfs_directory: parent_two)
        expect(dup).to be_valid
      end
    end

    context 'root directory path uniqueness' do
      let!(:existing_root) do
        create(:cfs_directory,
               :with_parent_file_group,
               path: 'duplicate_root',
               root_cfs_directory: nil).tap do |dir|
          dir.update!(root_cfs_directory: dir)
        end
      end

      it 'is invalid if another root directory has the same path' do
        dup = build(:cfs_directory,
                    :with_parent_file_group,
                    path: 'duplicate_root',
                    root_cfs_directory: nil)
        dup.root_cfs_directory = dup

        expect(dup).not_to be_valid
        expect(dup.errors[:base]).to include('Path must be unique for roots')
      end
    end
  end

  describe 'associations' do
    it { should have_many(:subdirectories).class_name('CfsDirectory').dependent(:destroy) }
    it { should have_many(:cfs_files).dependent(:destroy) }
    it { should belong_to(:parent).touch(true) }
    it { should belong_to(:root_cfs_directory).class_name('CfsDirectory') }
    it { should have_one(:job_cfs_initial_directory_assessment).class_name('Job::CfsInitialDirectoryAssessment').dependent(:destroy) }
  end

  describe 'instance methods' do
    let!(:root_dir) { create(:cfs_directory, :with_parent_file_group) }
    let!(:subdir) do
      create(:cfs_directory, :with_parent_directory, parent: root_dir, root_cfs_directory: root_dir)
    end

    describe '#root?' do
      context 'when directory is a root (parent is a FileGroup)' do
        it 'returns true' do
          expect(root_dir.root?).to be true
        end
      end

      context 'when directory is a subdirectory (parent is a CfsDirectory)' do
        it 'returns false' do
          expect(subdir.root?).to be false
        end
      end
    end

    describe '#non_root?' do
      context 'when directory is a root' do
        it 'returns false' do
          expect(root_dir.non_root?).to be false
        end
      end

      context 'when directory is a subdirectory' do
        it 'returns true' do
          expect(subdir.non_root?).to be true
        end
      end
    end

    describe '#leaf?' do
      context 'when directory has no subdirectories' do
        it 'returns true' do
          expect(subdir.leaf?).to be true
        end
      end

      context 'when directory has subdirectories' do
        before do
          create(:cfs_directory, :with_parent_directory, parent: subdir, root_cfs_directory: root_dir)
        end

        it 'returns false' do
          expect(subdir.leaf?).to be false
        end
      end
    end

    describe '#is_empty?' do
      context 'when directory has no files and is a leaf' do
        it 'returns true' do
          expect(subdir.is_empty?).to be true
        end
      end

      context 'when directory has files' do
        before do
          create(:cfs_file, cfs_directory: subdir)
        end

        it 'returns false' do
          expect(subdir.is_empty?).to be false
        end
      end

      context 'when directory has subdirectories (not a leaf)' do
        before do
          create(:cfs_directory, :with_parent_directory, parent: subdir, root_cfs_directory: root_dir)
        end

        it 'returns false' do
          expect(subdir.is_empty?).to be false
        end
      end
    end

    describe '#is_present_and_populated_on_storage?' do
      let(:directory) { create(:cfs_directory, :with_parent_file_group) }
      let(:storage_root) { double('StorageRoot') }

      before do
        allow(StorageManager).to receive_message_chain(:instance, :main_root).and_return(storage_root)
        allow(directory).to receive(:key).and_return('my/key/')
      end

      context 'when directory and files are present on storage' do
        it 'returns true' do
          allow(storage_root).to receive(:directory_key?).with('my/key/').and_return(true)
          allow(storage_root).to receive(:file_keys).with('my/key/').and_return(['file1.txt'])

          expect(directory.is_present_and_populated_on_storage?).to be true
        end
      end

      context 'when directory exists but no files are present' do
        it 'returns false' do
          allow(storage_root).to receive(:directory_key?).with('my/key/').and_return(true)
          allow(storage_root).to receive(:file_keys).with('my/key/').and_return([])

          expect(directory.is_present_and_populated_on_storage?).to be false
        end
      end

      context 'when directory does not exist on storage' do
        it 'returns false' do
          allow(storage_root).to receive(:directory_key?).with('my/key/').and_return(false)

          expect(directory.is_present_and_populated_on_storage?).to be false
        end
      end

      context 'when storage throws MedusaStorage::Error::InvalidDirectory' do
        it 'returns false' do
          allow(storage_root).to receive(:directory_key?).with('my/key/').and_raise(MedusaStorage::Error::InvalidDirectory.new('Medusa directory error'))
      
          expect(directory.is_present_and_populated_on_storage?).to be false
        end
      end
    end

    describe '#is_empty_or_missing_on_storage?' do
      let(:directory) { build_stubbed(:cfs_directory) }

      it 'returns true if is_present_and_populated_on_storage? is false' do
        allow(directory).to receive(:is_present_and_populated_on_storage?).and_return(false)
        expect(directory.is_empty_or_missing_on_storage?).to be true
      end

      it 'returns false if is_present_and_populated_on_storage? is true' do
        allow(directory).to receive(:is_present_and_populated_on_storage?).and_return(true)
        expect(directory.is_empty_or_missing_on_storage?).to be false
      end
    end

    describe '#recursive_subdirectory_ids' do
      let!(:root_dir) { create(:cfs_directory, :with_parent_file_group) }
      let!(:child1) do
        create(:cfs_directory, :with_parent_directory, parent: root_dir, root_cfs_directory: root_dir)
      end
      let!(:child2) do
        create(:cfs_directory, :with_parent_directory, parent: child1, root_cfs_directory: root_dir)
      end

      before do
        root_dir.update!(root_cfs_directory: root_dir)
      end

      context 'when called on the root directory' do
        it 'returns IDs of itself and all subdirectories' do
          expected_ids = CfsDirectory.where(root_cfs_directory_id: root_dir.id).pluck(:id)
          actual_ids = root_dir.recursive_subdirectory_ids
          expect(actual_ids.sort).to eq(expected_ids.sort)
        end
      end

      context 'when called on a non-root directory' do
        it 'returns IDs of itself and its descendants' do
          expected_ids = CfsDirectory.where(id: [child1.id, child2.id]).pluck(:id)
          actual_ids = child1.recursive_subdirectory_ids
          expect(actual_ids.sort).to eq(expected_ids.sort)
        end
      end
    end

    describe '#handle_cfs_assessment' do
      let(:old_file_group) { create(:bit_level_file_group) }
      let(:new_file_group) { create(:bit_level_file_group) }

      let!(:directory) do
        create(:cfs_directory,
              parent: old_file_group,
              parent_type: 'FileGroup',
              root_cfs_directory: nil)
      end

      before do
        # Setup saved previous state before parent change
        directory.update_column(:parent_id, old_file_group.id)
        directory.update_column(:parent_type, 'FileGroup')
      end

      context 'when the parent FileGroup has changed' do
        let!(:old_dir_job) do
          create(:cfs_initial_directory_assessment,
                file_group: old_file_group,
                cfs_directory: directory)
        end

        let!(:old_fg_job) do
          create(:cfs_initial_file_group_assessment,
                file_group: old_file_group)
        end

        before do
          # Setup stub of removal for old jobs
          allow_any_instance_of(Job::CfsInitialDirectoryAssessment)
            .to receive(:destroy_queued_jobs_and_self)
          allow_any_instance_of(Job::CfsInitialFileGroupAssessment)
            .to receive(:destroy_queued_jobs_and_self)

          allow(new_file_group).to receive(:schedule_initial_cfs_assessment)

          allow(directory).to receive(:reload_parent).and_return(new_file_group)
        end

        it 'destroys old jobs and schedules a new assessment' do
          # Setup the parent change
          directory.assign_attributes(parent: new_file_group, parent_type: 'FileGroup')

          # Setup proper tracking of the change
          allow(directory).to receive(:saved_change_to_parent_id?).and_return(true)
          allow(directory).to receive(:parent_type_before_last_save).and_return('FileGroup')

          directory.send(:handle_cfs_assessment)

          expect(new_file_group).to have_received(:schedule_initial_cfs_assessment)
        end
      end

      context 'when the parent did not change' do
        it 'does not schedule a new assessment' do
          allow(directory).to receive(:saved_change_to_parent_id?).and_return(false)
          allow(directory).to receive(:parent_type_before_last_save).and_return('FileGroup')
          allow(directory).to receive(:reload_parent)

          expect(directory.reload_parent).not_to receive(:schedule_initial_cfs_assessment)

          directory.send(:handle_cfs_assessment)
        end
      end

      context 'when the new parent is not a FileGroup' do
        it 'does not schedule a new assessment' do
          directory.parent_type = 'CfsDirectory'
          allow(directory).to receive(:saved_change_to_parent_id?).and_return(true)

          expect(directory).not_to receive(:reload_parent)

          directory.send(:handle_cfs_assessment)
        end
      end
    end
  end
end
