# read the workflow name from the CLI
wf_name = ARGV[0]


require "wfe"
require "logger"

# workflow engine options
opts = {
    :logger => Logger.new("/var/log/mktoutils/test.log"),
}
# datasource configs
db_conf = { :adapter  => "mysql2",
            :host     => "127.0.0.1",
            :username => "root",
            :password => "unlock",
            :database => "test"
}

# instantiate the engine
wfe = Wfe::Engine.new(db_conf, opts)

begin
  wfe.run(wf_name)
rescue Wfe::Exception=>e
  puts "unknown exception: %s" % [e.to_s]
rescue Wfe::WorkflowHalted=>e
  puts "workflow halted: %s" % [e.to_s]
rescue Wfe::StepError=>e
  puts "step error: %s" % [e.to_s]
rescue Wfe::WorkflowLocked=>e
  puts "workflow locked: %s" % [e.to_s]
rescue Wfe::WorkflowMIA=>e
  puts "workflow not found!: %s" % [wf_name]
rescue Wfe::ErrorState=>e
  puts "workflow in error state: %s" % [e.to_s]
end
