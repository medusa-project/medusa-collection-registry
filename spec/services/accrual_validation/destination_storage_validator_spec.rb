# frozen_string_literal: true

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

  # Fake destination storage root used instead of real S3.
  let(:storage_root) { double('destination_storage_root') }
  let(:storage_keys) { [] }

  # Fake staging storage root.
  let(:staging_root) { double('staging_root') }
  let(:staging_prefix) { 'Sousa/audio' }
  let(:staging_keys) { [] }

  before do
    destination_root.update!(root_cfs_directory: destination_root)

    allow(StorageManager.instance)
      .to receive(:main_root)
      .and_return(storage_root)

    allow(storage_root)
      .to receive(:subtree_keys)
      .with('606/2216')
      .and_return(storage_keys)

    allow(accrual_job)
      .to receive(:staging_root_and_prefix)
      .and_return([staging_root, staging_prefix])

    allow(staging_root)
      .to receive(:subtree_keys)
      .with(staging_prefix)
      .and_return(staging_keys)
  end

  describe '#call' do
    context 'when expected top-level files and directories exist in destination storage' do
      let(:staging_keys) do
        [
          'Sousa/audio/1209133/access/file_001.wav',
          'Sousa/audio/1209133/access/file_002.wav',
          'Sousa/audio/1209133/access/file_002.wav.vs'
        ]
      end

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

        expect(storage_root)
          .to have_received(:subtree_keys)
          .with('606/2216')
          .once
      end
    end

    context 'when destination storage includes directory marker keys' do
      let(:staging_keys) do
        [
          'Sousa/audio/1209133/',
          'Sousa/audio/1209133/access/',
          'Sousa/audio/1209133/access/file_001.wav',
          'Sousa/audio/1209133/access/file_002.wav',
          'Sousa/audio/1209133/access/file_003.wav',
          'Sousa/audio/1209133/access/file_004.wav',
          'Sousa/audio/1209133/access/file_005.wav'
        ]
      end

      let(:storage_keys) do
        [
          '606/2216/',
          '606/2216/1209133/',
          '606/2216/1209133/access/',
          '606/2216/1209133/access/file_001.wav',
          '606/2216/1209133/access/file_002.wav',
          '606/2216/1209133/access/file_003.wav',
          '606/2216/1209133/access/file_004.wav',
          '606/2216/1209133/access/file_005.wav'
        ]
      end

      before do
        create(
          :workflow_accrual_directory,
          workflow_accrual_job: accrual_job,
          name: '1209133',
          count: 5,
          size: 500.0
        )
      end

      it 'uses directory marker keys to detect directories but does not count them as files' do
        expect(result.valid).to eq(true)
        expect(result.expected_file_count).to eq(5)
        expect(result.actual_file_count).to eq(5)
        expect(result.missing_directories).to be_empty
        expect(result.directory_count_mismatches).to be_empty
      end
    end

    context 'when destination storage includes a package directory marker' do
      let(:staging_keys) do
        [
          'Sousa/audio/test_2/',
          'Sousa/audio/test_2/5958513_highres_opt_opt.pdf',
          'Sousa/audio/test_2/99162161812205899-001.tif',
          'Sousa/audio/test_2/99955291084505899-001.tif',
          'Sousa/audio/test_2/SRS-404.pdf',
          'Sousa/audio/test_2/SRS-444.pdf'
        ]
      end

      let(:storage_keys) do
        [
          '606/2216/test_2/',
          '606/2216/test_2/5958513_highres_opt_opt.pdf',
          '606/2216/test_2/99162161812205899-001.tif',
          '606/2216/test_2/99955291084505899-001.tif',
          '606/2216/test_2/SRS-404.pdf',
          '606/2216/test_2/SRS-444.pdf'
        ]
      end

      before do
        create(
          :workflow_accrual_directory,
          workflow_accrual_job: accrual_job,
          name: 'test_2',
          count: 5,
          size: 500.0
        )
      end

      it 'does not count the package directory marker as a file' do
        expect(result.valid).to eq(true)
        expect(result.expected_file_count).to eq(5)
        expect(result.actual_file_count).to eq(5)
        expect(result.missing_directories).to be_empty
        expect(result.directory_count_mismatches).to be_empty
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
      let(:staging_keys) do
        [
          'Sousa/audio/1209133/file_001.wav',
          'Sousa/audio/1209133/file_002.wav'
        ]
      end

      let(:storage_keys) do
        [
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
      let(:staging_keys) do
        [
          'Sousa/audio/1209133/access/file_001.wav',
          'Sousa/audio/1209133/access/file_002.wav'
        ]
      end

      let(:storage_keys) do
        [
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
      let(:staging_keys) do
        [
          'Sousa/audio/1209133/access/file_001.wav'
        ]
      end

      let(:storage_keys) do
        [
          '606/2216/metadata.csv',
          '606/2216/1209133/access/file_001.wav',
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

    context 'when .vs files are part of the accrual' do
      let(:staging_keys) do
        [
          'Sousa/audio/1209133/access/file_001.wav',
          'Sousa/audio/1209133/access/file_001.wav.vs'
        ]
      end

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

      it 'counts .vs files when they belong to the current accrual' do
        expect(result.valid).to eq(true)
        expect(result.expected_file_count).to eq(2)
        expect(result.actual_file_count).to eq(2)
      end
    end

    context 'when destination storage is empty' do
      let(:staging_keys) do
        [
          'Sousa/audio/1209133/file_001.wav',
          'Sousa/audio/1209133/file_002.wav'
        ]
      end

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

    # Regression for accrual 185 behavior.
    context 'when adding a file to an existing destination directory' do
      let(:staging_keys) do
        [
          'Sousa/audio/pdi/new_validation_test.txt'
        ]
      end

      let(:storage_keys) do
        [
          '606/2216/pdi/old_01.txt',
          '606/2216/pdi/old_02.txt',
          '606/2216/pdi/old_03.txt',
          '606/2216/pdi/old_04.txt',
          '606/2216/pdi/new_validation_test.txt'
        ]
      end

      before do
        create(
          :workflow_accrual_directory,
          workflow_accrual_job: accrual_job,
          name: 'pdi',
          count: 1,
          size: 100.0
        )
      end

      it 'ignores historical files and validates only the current accrual file' do
        expect(result.valid).to eq(true)
        expect(result.expected_file_count).to eq(1)
        expect(result.actual_file_count).to eq(1)
        expect(result.missing_files).to be_empty
        expect(result.missing_directories).to be_empty
        expect(result.directory_count_mismatches).to be_empty
        expect(result.blocking_failures).to be_empty
      end
    end
  end
end