require 'factory_girl'
require 'wfe'
require 'active_record'

obj = ActiveRecord::Base.establish_connection(
    :adapter  => "mysql2",
    :host     => "127.0.0.1",
    :username => "root",
    :password => "unlock",
    :database => "test"
)



FactoryGirl.find_definitions
wf = FactoryGirl.build(:workflow_good)
require 'pp'
pp wf
pp wf.steps

