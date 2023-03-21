class AddStateToWorkflowGlobusTransfer < ActiveRecord::Migration[7.0]
  def change
    add_column :workflow_globus_transfers, :state, :string
  end
end
