# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Workflow::AccrualJob, type: :model do
  describe '#perform_assessing' do
    let(:destination_root) do
      create(:cfs_directory, :with_parent_file_group).tap do |directory|
        directory.update!(root_cfs_directory: directory)
      end
    end

    let(:accrual_job) do
      create(
        :workflow_accrual_job,
        cfs_directory: destination_root,
        state: 'assessing',
        assessment_start_time: nil,
        assessment_attempt_count: nil
      )
    end

    before do
      accrual_job # Persist before measuring new Delayed Jobs.

      # with_lock reloads the accrual; consistently return the same directory
      # instance so the scheduling spy survives that reload.
      allow(accrual_job).to receive(:cfs_directory).and_return(destination_root)
      allow(destination_root).to receive(:make_and_assess_tree)
    end

    it 'schedules the assessment, saves its checkpoint, and queues the next state' do
      expect { accrual_job.perform_assessing }
        .to change(Delayed::Job, :count).by(1)

      expect(destination_root).to have_received(:make_and_assess_tree).once
      expect(accrual_job.reload.state).to eq('await_assessment')
      expect(accrual_job.assessment_start_time).to be_present
      expect(accrual_job.assessment_attempt_count).to eq(1)

      next_job = Delayed::Job.order(id: :desc).first
      expect(next_job.handler).to include('Workflow::AccrualJob')
      expect(next_job.run_at).to be_within(3.seconds).of(30.seconds.from_now)
    end

    it 'does not schedule again if initialization was already checkpointed' do
      original_start_time = 5.minutes.ago
      accrual_job.update!(
        assessment_start_time: original_start_time,
        assessment_attempt_count: 2
      )

      accrual_job.perform_assessing

      expect(destination_root).not_to have_received(:make_and_assess_tree)
      expect(accrual_job.reload.state).to eq('await_assessment')
      expect(accrual_job.assessment_start_time).to be_within(1.second).of(original_start_time)
      expect(accrual_job.assessment_attempt_count).to eq(2)
    end

    it 'does not reject an existing directory assessment job during a retry' do
      # This reproduces the old duplicate-attempt guard scenario.
      # Use the actual directory scheduling method to confirm it does not
      # create a second directory assessment record.
      allow(destination_root).to receive(:make_and_assess_tree).and_call_original
      Job::CfsInitialDirectoryAssessment.create_for(
        destination_root, destination_root.file_group
      )
      count_before = Job::CfsInitialDirectoryAssessment
        .where(cfs_directory_id: destination_root.id).count

      expect { accrual_job.perform_assessing }.not_to change {
        Job::CfsInitialDirectoryAssessment
          .where(cfs_directory_id: destination_root.id).count
      }

      expect(count_before).to eq(1)
      expect(accrual_job.reload.state).to eq('await_assessment')
    end

    it 'rolls back the checkpoint and state if queueing fails, then retries' do
      allow(accrual_job).to receive(:put_in_queue)
        .and_raise(StandardError, 'simulated enqueue failure')

      expect { accrual_job.perform_assessing }
        .to raise_error(StandardError, 'simulated enqueue failure')

      expect(accrual_job.reload.state).to eq('assessing')
      expect(accrual_job.assessment_start_time).to be_nil
      expect(accrual_job.assessment_attempt_count).to be_nil

      allow(accrual_job).to receive(:put_in_queue).and_call_original
      accrual_job.perform_assessing

      expect(destination_root).to have_received(:make_and_assess_tree).twice
      expect(accrual_job.reload.state).to eq('await_assessment')
      expect(accrual_job.assessment_start_time).to be_present
    end

    it 'does nothing if the workflow has already left assessing' do
      accrual_job.update!(state: 'await_assessment')

      expect { accrual_job.perform_assessing }
        .not_to change(Delayed::Job, :count)

      expect(destination_root).not_to have_received(:make_and_assess_tree)
      expect(accrual_job.reload.state).to eq('await_assessment')
    end
  end
end
