# Workflow extends ActiveRecord::Base and is used to define and store workflow
#
# Author::    jacques@marketo.com
#
class Wfe::Workflow < ActiveRecord::Base
  self.table_name = 'workflow'
  serialize :init_time_ctx
  serialize :run_time_ctx
  has_many :steps , :class_name  => "WorkflowStep",
           :foreign_key => "workflow_id", :autosave => true , :dependent => :delete_all

  # Indicates the workflow has not been ran yet.
  STATE_PENDING = 'pending'
  # indicates the workflow was started. This means the workflow is running or its process exit ungracefully
  STATE_STARTED = 'started'
  # indicates the workflow ran into a failure condition and cannot be resumed until the error step is corrected
  STATE_ERROR = 'error'
  # indicates the workflow has ran and completed without any failures.
  STATE_COMPLETED = 'completed'
end

class Wfe::WorkflowMigration < ActiveRecord::Migration

  def create
    create_table :workflow, :options => "ENGINE=InnoDB"do |t|
      t.string :name, :null => false
      t.text :init_time_ctx, :null => false
      t.text :run_time_ctx, :null => false
      t.datetime :scheduled, :null => false
      t.datetime :start
      t.datetime :end
      t.datetime :created_at, :null => false
      t.string :state, :default => Wfe::Workflow::STATE_PENDING
    end
  end

end