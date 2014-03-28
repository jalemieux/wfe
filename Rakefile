require "bundler/gem_tasks"
#require File.join(File.dirname(__FILE__), 'lib/wfe.rb')
$: << File.join(File.dirname(__FILE__), 'lib/')
require 'wfe'

ENV['gem_dir_root'] = File.dirname(__FILE__)


desc "runs db test setup, and rspecs"
task :run_tests => [:db_setup_test_database, :rspec] do

end

desc "runs coverage report"
task :coverage => :run_tests do
  ENV["COVERAGE"] = 'true'
end

