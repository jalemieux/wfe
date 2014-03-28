

db_conf_file = File.join(ENV['gem_dir_root'], 'conf/db_conf.yml')
db_conf = YAML.load_file(db_conf_file)

run_migrations = lambda do ||
  Dir[ File.join(ENV['gem_dir_root'], 'migrations/*_migration.rb') ].each do |file|
    puts file.to_s
    require file
  end
  #require File.join(ENV['gem_dir_root'], 'migrations/workflow_migration.rb')
  #require File.join(ENV['gem_dir_root'], 'migrations/workflow_step_migration.rb')
  m1 = Wfe::WorkflowMigration.new.create
  m2 = Wfe::WorkflowStepMigration.new.create
  m3 = Wfe::LockMigration.new.create
end

task :migrations do

end

desc "Drop and Creates the DB wfe_test tables using 'test' configuration in #{db_conf_file}"
task :db_setup_test_database => :migrations do
  ActiveRecord::Base.establish_connection(db_conf['test'])
  ActiveRecord::Base.connection.drop_database(db_conf['test']['database']) rescue nil
  ActiveRecord::Base.connection.create_database(db_conf['test']['database'])
  ActiveRecord::Base.establish_connection(db_conf['test'])
  #puts Wfe::Workflow::STATE_PENDING.to_s
  run_migrations.call
end

desc "Creates the DB wfe and tables using 'prod' configuration in #{db_conf_file}"
task :db_setup_database => :migrations do
  ActiveRecord::Base.establish_connection(db_conf['prod'])
  ActiveRecord::Base.connection.create_database(db_conf['prod']['database'])
  ActiveRecord::Base.establish_connection(db_conf['prod'])
  run_migrations.call
end
