# spec/services/accrual_validation/expected_ingest_set_validator_spec.rb

require 'rails_helper'

RSpec.describe AccrualValidation::ExpectedIngestSetValidator do
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

  before do
    destination_root.update!(root_cfs_directory: destination_root)
  end

  describe '#call' do
    context 'when expected files and directories exist with matching counts' do
      before do
        create(
          :workflow_accrual_file,
          workflow_accrual_job: accrual_job,
          name: 'metadata.csv'
        )

        create(
          :workflow_accrual_directory,
          workflow_accrual_job: accrual_job,
          name: '1209133',
          count: 2
        )

        package_directory = create(
          :cfs_directory,
          :with_parent_directory,
          parent: destination_root,
          root_cfs_directory: destination_root,
          path: '606/2216/1209133'
        )

        create(
          :cfs_file,
          cfs_directory: destination_root,
          name: 'metadata.csv'
        )

        create(
          :cfs_file,
          cfs_directory: package_directory,
          name: 'file_001.wav'
        )

        create(
          :cfs_file,
          cfs_directory: package_directory,
          name: 'file_002.wav'
        )
      end

      it 'returns valid true' do
        expect(result.valid).to eq(true)
      end

      it 'has no blocking failures' do
        expect(result.blocking_failures).to be_empty
      end

      it 'reports matching expected and actual file counts' do
        expect(result.expected_file_count).to eq(3)
        expect(result.actual_file_count).to eq(3)
      end

      it 'has no missing files or directories' do
        expect(result.missing_files).to be_empty
        expect(result.missing_directories).to be_empty
        expect(result.directory_count_mismatches).to be_empty
      end
    end

    context 'when an expected top-level file is missing' do
      before do
        create(
          :workflow_accrual_file,
          workflow_accrual_job: accrual_job,
          name: 'metadata.csv'
        )
      end

      it 'returns valid false' do
        expect(result.valid).to eq(false)
      end

      it 'reports the missing file' do
        expect(result.missing_files).to include('metadata.csv')
      end

      it 'adds a blocking failure' do
        expect(result.blocking_failures).to include(
          'One or more expected top-level files are missing from the ingested result.'
        )
      end

      it 'reports the actual file count correctly' do
        expect(result.expected_file_count).to eq(1)
        expect(result.actual_file_count).to eq(0)
      end
    end

    context 'when an expected directory is missing' do
      before do
        create(
          :workflow_accrual_directory,
          workflow_accrual_job: accrual_job,
          name: '1209133',
          count: 2
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
          'One or more expected accrual directories are missing from the ingested result.'
        )
      end
    end

    context 'when an expected directory exists but has the wrong file count' do
      before do
        create(
          :workflow_accrual_directory,
          workflow_accrual_job: accrual_job,
          name: '1209133',
          count: 2
        )

        package_directory = create(
          :cfs_directory,
          :with_parent_directory,
          parent: destination_root,
          root_cfs_directory: destination_root,
          path: '606/2216/1209133'
        )

        create(
          :cfs_file,
          cfs_directory: package_directory,
          name: 'file_001.wav'
        )
      end

      it 'returns valid false' do
        expect(result.valid).to eq(false)
      end

      it 'reports the count mismatch' do
        expect(result.directory_count_mismatches).to include(
          directory: '1209133',
          expected: 2,
          actual: 1
        )
      end

      it 'adds a blocking failure' do
        expect(result.blocking_failures).to include(
          'One or more expected accrual directories have an incorrect ingested file count.'
        )
      end
    end
  end
end