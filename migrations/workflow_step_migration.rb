class Wfe::WorkflowStepMigration < ActiveRecord::Migration
  def create
    create_table :workflow_step, :options => "ENGINE=InnoDB" do |t|
      t.string :name, :null => false
      t.string :impl_class, :null => false
      t.text :args
      t.integer :workflow_id, :null => false
      t.string :state, :default => Wfe::WorkflowStep::STATE_PENDING
    end

    execute <<-SQL
      ALTER TABLE workflow_step
        ADD
        FOREIGN KEY (workflow_id)
        REFERENCES workflow(id)
    SQL
  end
end