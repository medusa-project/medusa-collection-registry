# spec/services/accrual_validation/assessment_completion_validator_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccrualValidation::AssessmentCompletionValidator do
  subject(:result) { described_class.new(accrual_job: accrual_job).call }

  let(:destination_root) do
    create(
      :cfs_directory,
      :with_parent_file_group,
      path: '606/2216'
    )
  end

  let(:file_group) { destination_root.file_group }

  let(:accrual_job) do
    create(
      :workflow_accrual_job,
      cfs_directory: destination_root,
      state: 'final_validation'
    )
  end

  before do
    destination_root.update!(root_cfs_directory: destination_root)
  end

  def create_file_in_accrual_tree(name:, md5_sum: 'abc123', fits_serialized: true)
    create(
      :cfs_file,
      cfs_directory: destination_root,
      name: name,
      md5_sum: md5_sum,
      fits_serialized: fits_serialized
    )
  end

  def create_complete_assessor_task_for(cfs_file)
    task_element = create(
      :assessor_task_element,
      cfs_file: cfs_file,
      checksum: true,
      content_type: true,
      fits: true,
      sent_at: Time.current
    )

    create(
      :assessor_response,
      assessor_task_element: task_element,
      subtask: 'checksum',
      status: 'handled'
    )

    create(
      :assessor_response,
      assessor_task_element: task_element,
      subtask: 'content_type',
      status: 'handled'
    )

    create(
      :assessor_response,
      assessor_task_element: task_element,
      subtask: 'fits',
      status: 'handled'
    )

    task_element
  end

  describe '#call' do
    context 'when assessment is fully complete' do
      let!(:cfs_file) do
        create_file_in_accrual_tree(
          name: 'test_file.wav',
          md5_sum: 'test123',
          fits_serialized: true
        )
      end

      before do
        create_complete_assessor_task_for(cfs_file)
      end

      it 'returns valid true' do
        expect(result.valid).to eq(true)
      end

      it 'has no blocking failures' do
        expect(result.blocking_failures).to be_empty
      end

      it 'reports the checked file count' do
        expect(result.checked_file_count).to eq(1)
      end

      it 'reports no incomplete assessment state' do
        expect(result.missing_checksum_count).to eq(0)
        expect(result.missing_fits_count).to eq(0)
        expect(result.incomplete_assessor_task_count).to eq(0)
        expect(result.assessor_error_count).to eq(0)
        expect(result.pending_assessment_job_count).to eq(0)
      end
    end

    context 'when a file is missing a checksum' do
      let!(:cfs_file) do
        create_file_in_accrual_tree(
          name: 'missing_checksum.wav',
          md5_sum: nil,
          fits_serialized: true
        )
      end

      it 'returns valid false' do
        expect(result.valid).to eq(false)
      end

      it 'reports the missing checksum file' do
        expect(result.missing_checksum_count).to eq(1)
        expect(result.missing_checksum_file_ids).to contain_exactly(cfs_file.id)
      end

      it 'adds a blocking failure' do
        expect(result.blocking_failures).to include(
          'One or more files are missing checksum values.'
        )
      end
    end

    context 'when a file is missing FITS serialization' do
      let!(:cfs_file) do
        create_file_in_accrual_tree(
          name: 'missing_fits.wav',
          md5_sum: 'test123',
          fits_serialized: false
        )
      end

      it 'returns valid false' do
        expect(result.valid).to eq(false)
      end

      it 'reports the missing FITS file' do
        expect(result.missing_fits_count).to eq(1)
        expect(result.missing_fits_file_ids).to contain_exactly(cfs_file.id)
      end

      it 'adds a blocking failure' do
        expect(result.blocking_failures).to include(
          'One or more files are missing FITS serialization.'
        )
      end
    end

    context 'when an assessor task was never sent' do
      let!(:cfs_file) do
        create_file_in_accrual_tree(
          name: 'unsent.wav',
          md5_sum: 'unsent123',
          fits_serialized: true
        )
      end

      let!(:task_element) do
        create(
          :assessor_task_element,
          cfs_file: cfs_file,
          checksum: true,
          content_type: true,
          fits: true,
          sent_at: nil
        )
      end

      it 'returns valid false' do
        expect(result.valid).to eq(false)
      end

      it 'reports the incomplete assessor task' do
        expect(result.incomplete_assessor_task_count).to eq(1)
        expect(result.incomplete_assessor_task_ids).to contain_exactly(task_element.id)
      end

      it 'adds a blocking failure' do
        expect(result.blocking_failures).to include(
          'One or more assessor tasks are incomplete.'
        )
      end
    end

    context 'when an assessor task has an unhandled response' do
      let!(:cfs_file) do
        create_file_in_accrual_tree(
          name: 'unhandled_response.wav',
          md5_sum: 'test123',
          fits_serialized: true
        )
      end

      let!(:task_element) do
        create(
          :assessor_task_element,
          cfs_file: cfs_file,
          checksum: true,
          content_type: false,
          fits: false,
          sent_at: Time.current
        )
      end

      before do
        create(
          :assessor_response,
          assessor_task_element: task_element,
          subtask: 'checksum',
          status: 'fetched'
        )
      end

      it 'returns valid false' do
        expect(result.valid).to eq(false)
      end

      it 'reports the incomplete assessor task' do
        expect(result.incomplete_assessor_task_count).to eq(1)
        expect(result.incomplete_assessor_task_ids).to contain_exactly(task_element.id)
      end

      it 'adds a blocking failure' do
        expect(result.blocking_failures).to include(
          'One or more assessor tasks are incomplete.'
        )
      end
    end

    context 'when an assessor task has an error response' do
      let!(:cfs_file) do
        create_file_in_accrual_tree(
          name: 'error_response.wav',
          md5_sum: 'test123',
          fits_serialized: true
        )
      end

      let!(:task_element) do
        create(
          :assessor_task_element,
          cfs_file: cfs_file,
          checksum: false,
          content_type: false,
          fits: false,
          sent_at: Time.current
        )
      end

      before do
        create(
          :assessor_response,
          assessor_task_element: task_element,
          subtask: 'error',
          status: 'handled'
        )
      end

      it 'returns valid false' do
        expect(result.valid).to eq(false)
      end

      it 'reports the assessor error task' do
        expect(result.assessor_error_count).to eq(1)
        expect(result.assessor_error_task_ids).to contain_exactly(task_element.id)
      end

      it 'adds a blocking failure' do
        expect(result.blocking_failures).to include(
          'One or more assessor tasks have error responses.'
        )
      end
    end

    context 'when a directory assessment job is still pending' do
      let!(:child_directory) do
        create(
          :cfs_directory,
          :with_parent_directory,
          parent: destination_root,
          path: '606/2216/1209133',
          root_cfs_directory: destination_root
        )
      end

      before do
        # Create the pending assessment job row directly.
        #
        # Do not use Job::CfsInitialDirectoryAssessment.create_for here because
        # create_for also enqueues a delayed job. This validator spec only needs
        # the database row so it can verify the pending job detection logic.
        Job::CfsInitialDirectoryAssessment.create!(
          file_group: file_group,
          cfs_directory: child_directory,
          file_count: 1
        )
      end

      it 'returns valid false' do
        expect(result.valid).to eq(false)
      end

      it 'reports the pending assessment job directory id' do
        expect(result.pending_assessment_job_count).to eq(1)
        expect(result.pending_assessment_job_directory_ids).to contain_exactly(child_directory.id)
      end

      it 'adds a blocking failure' do
        expect(result.blocking_failures).to include(
          'One or more directory assessment jobs are still pending.'
        )
      end
    end

    context 'when multiple assessment problems exist' do
      let!(:missing_checksum_file) do
        create_file_in_accrual_tree(
          name: 'missing_checksum.wav',
          md5_sum: nil,
          fits_serialized: true
        )
      end

      let!(:missing_fits_file) do
        create_file_in_accrual_tree(
          name: 'missing_fits.wav',
          md5_sum: 'test123',
          fits_serialized: false
        )
      end

      let!(:incomplete_task_file) do
        create_file_in_accrual_tree(
          name: 'incomplete_task.wav',
          md5_sum: 'test123',
          fits_serialized: true
        )
      end

      let!(:task_element) do
        create(
          :assessor_task_element,
          cfs_file: incomplete_task_file,
          checksum: true,
          content_type: false,
          fits: false,
          sent_at: nil
        )
      end

      it 'returns valid false' do
        expect(result.valid).to eq(false)
      end

      it 'reports each failure category without stopping after the first one' do
        expect(result.missing_checksum_file_ids).to contain_exactly(missing_checksum_file.id)
        expect(result.missing_fits_file_ids).to contain_exactly(missing_fits_file.id)
        expect(result.incomplete_assessor_task_ids).to contain_exactly(task_element.id)
      end

      it 'includes multiple blocking failures' do
        expect(result.blocking_failures).to include(
          'One or more files are missing checksum values.',
          'One or more files are missing FITS serialization.',
          'One or more assessor tasks are incomplete.'
        )
      end
    end

    context 'when the accrual job has no destination CFS directory' do
      let(:accrual_job) do
        build(
          :workflow_accrual_job,
          cfs_directory: nil,
          state: 'final_validation'
        )
      end

      it 'returns valid false' do
        expect(result.valid).to eq(false)
      end

      it 'reports the missing destination CFS directory' do
        expect(result.cfs_directory_id).to be_nil
        expect(result.checked_file_count).to eq(0)
        expect(result.blocking_failures).to include(
          'Accrual job does not have a destination CFS directory.'
        )
      end
    end
  end
end