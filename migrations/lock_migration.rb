class Wfe::LockMigration < ActiveRecord::Migration
  def create
    create_table :semaphore, :options => "ENGINE=InnoDB"do |t|
      t.string :name, :null => false, :unique => true
      t.datetime :locked_until, :null => false
    end
  end
end