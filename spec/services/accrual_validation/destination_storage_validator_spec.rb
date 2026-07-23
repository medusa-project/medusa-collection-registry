# spec/services/accrual_validation/destination_storage_validator_spec.rb

require 'rails_helper'

RSpec.describe AccrualValidation::DestinationStorageValidator do
  subject(:result) { described_class.new(accrual_job: accrual_job).call }

  let(:destination_root) do
    create(
      :cfs_directory,
      :with_parent_file_group,
      path: '606/2216'
    )
  end

  let(:accrual_job) do
    create(
      :workflow_accrual_job,
      cfs_directory: destination_root,
      staging_path: '/AVPres/Sousa/audio/',
      state: 'await_assessment'
    )
  end

  # Fake storage root used instead of real S3.
  #
  # Production uses:
  #
  # StorageManager.instance.main_root
  # => MedusaStorage::Root::S3
  #
  # stub the storage root so the validator can run without
  # touching real Medusa storage.
  let(:storage_root) { double('MedusaStorage::Root::S3') }

  let(:storage_keys) { [] }

  before do
    destination_root.update!(root_cfs_directory: destination_root)

    # Stubs the main Medusa storage root.
    #
    # This prevents the spec from calling real S3.
    allow(StorageManager.instance).to receive(:main_root).and_return(storage_root)

    # subtree_keys is from the MedusaStorage API.
    #
    # It returns all storage keys under a directory prefix.
    #
    # storage_root.subtree_keys("606/2216")
    allow(storage_root).to receive(:subtree_keys)
      .with('606/2216')
      .and_return(storage_keys)
  end

  describe '#call' do
    context 'when expected top-level files and directories exist in destination storage' do
      let(:storage_keys) do
        [
          '606/2216/metadata.csv',
          '606/2216/1209133/access/file_001.wav',
          '606/2216/1209133/access/file_002.wav',
          '606/2216/1209133/access/file_002.wav.vs'
        ]
      end

      before do
        create(
          :workflow_accrual_file,
          workflow_accrual_job: accrual_job,
          name: 'metadata.csv',
          size: 100.0
        )
        
        create(
          :workflow_accrual_directory,
          workflow_accrual_job: accrual_job,
          name: '1209133',
          count: 3,
          size: 300.0
        )
      end

      it 'returns valid true' do
        expect(result.valid).to eq(true)
      end

      it 'has no blocking failures' do
        expect(result.blocking_failures).to be_empty
      end

      it 'reports matching expected and actual file counts' do
        expect(result.expected_file_count).to eq(4)
        expect(result.actual_file_count).to eq(4)
      end

      it 'has no missing files, missing directories, or count mismatches' do
        expect(result.missing_files).to be_empty
        expect(result.missing_directories).to be_empty
        expect(result.directory_count_mismatches).to be_empty
      end

      it 'uses subtree_keys once for the destination prefix' do
        result

        expect(storage_root).to have_received(:subtree_keys)
          .with('606/2216')
          .once
      end
    end

    context 'when an expected top-level file is missing from destination storage' do
      let(:storage_keys) do
        [
          '606/2216/1209133/access/file_001.wav'
        ]
      end

      before do
        create(
          :workflow_accrual_file,
          workflow_accrual_job: accrual_job,
          name: 'metadata.csv',
          size: 100.0
        )
      end

      it 'returns valid false' do
        expect(result.valid).to eq(false)
      end

      it 'reports the missing top-level file' do
        expect(result.missing_files).to include('metadata.csv')
      end

      it 'adds a blocking failure' do
        expect(result.blocking_failures).to include(
          'One or more expected top-level files are missing from destination storage.'
        )
      end

      it 'reports the actual storage file count correctly' do
        expect(result.expected_file_count).to eq(1)
        expect(result.actual_file_count).to eq(0)
      end
    end

    context 'when an expected directory is missing from destination storage' do
      let(:storage_keys) do
        [
          # Storage has a top-level file, but nothing under it
          #
          # 606/2216/1209133/
          '606/2216/metadata.csv'
        ]
      end

      before do
        create(
          :workflow_accrual_directory,
          workflow_accrual_job: accrual_job,
          name: '1209133',
          count: 2,
          size: 200.0
        )
      end

      it 'returns valid false' do
        expect(result.valid).to eq(false)
      end

      it 'reports the missing directory' do
        expect(result.missing_directories).to include('1209133')
      end

      it 'adds a blocking failure' do
        expect(result.blocking_failures).to include(
          'One or more expected accrual directories are missing from destination storage.'
        )
      end
    end

    context 'when an expected directory exists but has the wrong storage file count' do
      let(:storage_keys) do
        [
          # The expected package directory exists, but it only contains one file.
          #
          # Expected count is 2.
          '606/2216/1209133/access/file_001.wav'
        ]
      end

      before do
        create(
          :workflow_accrual_directory,
          workflow_accrual_job: accrual_job,
          name: '1209133',
          count: 2,
          size: 200.0
        )
      end

      it 'returns valid false' do
        expect(result.valid).to eq(false)
      end

      it 'reports the directory count mismatch' do
        expect(result.directory_count_mismatches).to include(
          directory: '1209133',
          expected: 2,
          actual: 1
        )
      end

      it 'adds a blocking failure' do
        expect(result.blocking_failures).to include(
          'One or more expected accrual directories have an incorrect destination storage file count.'
        )
      end
    end

    context 'when destination storage contains unrelated extra files' do
      let(:storage_keys) do
        [
          # Expected top-level file.
          '606/2216/metadata.csv',

          # Expected package file.
          '606/2216/1209133/access/file_001.wav',

          # Unrelated package directory.
          '606/2216/9999999/access/extra_file.wav'
        ]
      end

      before do
        create(
          :workflow_accrual_file,
          workflow_accrual_job: accrual_job,
          name: 'metadata.csv',
          size: 100.0
        )

        create(
          :workflow_accrual_directory,
          workflow_accrual_job: accrual_job,
          name: '1209133',
          count: 1,
          size: 100.0
        )
      end

      it 'does not count unrelated storage keys against the accrual' do
        expect(result.valid).to eq(true)
        expect(result.expected_file_count).to eq(2)
        expect(result.actual_file_count).to eq(2)
      end
    end

    context 'when .vs files are part of the destination storage result' do
      let(:storage_keys) do
        [
          '606/2216/1209133/access/file_001.wav',
          '606/2216/1209133/access/file_001.wav.vs'
        ]
      end

      before do
        create(
          :workflow_accrual_directory,
          workflow_accrual_job: accrual_job,
          name: '1209133',
          count: 2,
          size: 200.0
        )
      end

      it 'counts .vs files as real destination storage files' do
        expect(result.valid).to eq(true)
        expect(result.expected_file_count).to eq(2)
        expect(result.actual_file_count).to eq(2)
      end
    end

    context 'when destination storage is empty' do
      let(:storage_keys) { [] }

      before do
        create(
          :workflow_accrual_file,
          workflow_accrual_job: accrual_job,
          name: 'metadata.csv',
          size: 100.0
        )

        create(
          :workflow_accrual_directory,
          workflow_accrual_job: accrual_job,
          name: '1209133',
          count: 2,
          size: 200.0
        )
      end

      it 'returns valid false' do
        expect(result.valid).to eq(false)
      end

      it 'reports missing files and directories' do
        expect(result.missing_files).to include('metadata.csv')
        expect(result.missing_directories).to include('1209133')
      end

      it 'reports actual file count as zero' do
        expect(result.expected_file_count).to eq(3)
        expect(result.actual_file_count).to eq(0)
      end
    end
  end
end