require File.join(File.dirname(__FILE__), '../lib/wfe.rb')
require "logger"
require 'factory_girl'

$db_conf = {
    :adapter  => "mysql2",
    :host     => "127.0.0.1",
    :username => "root",
    :password => "unlock",
    :database => "wfe_test"
}

#puts FactoryGirl.definition_file_paths
obj = ActiveRecord::Base.establish_connection($db_conf)


RSpec.configure do |config|
  FactoryGirl.find_definitions
  config.include FactoryGirl::Syntax::Methods
end


