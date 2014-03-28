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