
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


# define the sequence of steps, using the class names
steps = [ Wfe::Steps::RunOnRemoteHosts ]

# arguments that should be in the context of the workflow
# at init time
init_time_ctx = {
    :hosts =>  ['intweb1', 'intweb2', 'intbe1', 'intbe2'],
    :cmd_to_run => "uname -a"
}

# instantiate the engine
wfe = Wfe::Engine.new(db_conf, opts)

# pick a unique name
wf_name = "my_workflow_name_%d" % [Time.now.to_i]

begin
  wf = wfe.create_workflow(
    wf_name,
    init_time_ctx,
    steps,
)
rescue Wfe::Exception=>e
  puts "unknown exception: %s" % [e.to_s]
rescue Wfe::WorkflowHalted=>e
  puts "workflow halted: %s" % [e.to_s]
rescue Wfe::StepError=>e
  puts "step error: %s" % [e.to_s]
rescue Wfe::WorkflowLocked=>e
  puts "workflow locked: %s" % [e.to_s]
rescue Wfe::ErrorState=>e
  puts "workflow in error state: %s" % [e.to_s]
end
