
lib = File.expand_path(File.join(File.dirname(__FILE__), '../lib'))
$: << lib unless $:.include?(lib)

require "wfe"
require "logger"



class BuildApp < Wfe::BaseStep
  def work(ctx)
    raise Exception.new("cannot find the tag in the context!") if ctx[:app_tag_name].nil?
    print "i'm building the app!\n"
    sleep 2
    ctx[:app_tar_name] = 'build-%s.tgz' % [ctx[:app_tag_name]]
    ctx[:app_tar_location] = 'mmc.marketo.org:/home/deployer'
  end

end

class StopApp < Wfe::BaseStep
  def work(ctx)
    raise Exception.new("cannot find the servers in the context!") if ctx[:target_servers].nil?
    ctx[:target_servers].each { |s| print "i'm stopping server %s!\n" % [s]  }
    sleep 2
  end
end

class PushApp < Wfe::BaseStep
  def work(ctx)
    raise Exception.new("cannot find the app tar in the context!") if ctx[:app_tar_location].nil?
    ctx[:target_servers].each { |s| print "i'm pushing the app [%s] to server %s!\n" % [ctx[:app_tar_location],s]  }
    sleep 2
  end
end

class ErrorStep < Wfe::BaseStep
  def work(ctx)
    raise Exception.new("ow, i dont know what happened!")
  end
end

class StartApp < Wfe::BaseStep
  def work(ctx)
    raise Exception.new("cannot find the servers in the context!") if ctx[:target_servers].nil?
    ctx[:target_servers].each { |s| print "i'm starting server %s!\n" % [s]  }
    sleep 2
  end
end

## workflow engine operational settings
# workflow engine options
opts = {
    :logger => Logger.new("/var/log/mktoutils/test.log"),
}
# datarsource configs
db_conf = { :adapter  => "mysql2",
            :host     => "127.0.0.1",
            :username => "root",
            :password => "unlock",
            :database => "test"
}

## workflow engine manifestspecific settings
## shoudl come from manifest and user input

# uncomment if you want to create a new workflow each time
# wf_name = 'deploy_mlm_poda-%d' %[rand(1000)]
wf_name = 'deploy_mlm_pod%s' % [ARGV.first]

# define the sequence of steps
step_sequence = [ BuildApp, StopApp, PushApp, StartApp]
bad_step_sequence = [ BuildApp, ErrorStep , StartApp ]

# arguments that should be in the context of the workflow
# at init time
init_time_ctx = {
    :app_tag_name => 'tag-123-123-123',
    :target_servers => ['intweb1', 'intweb2', 'intbe1', 'intbe2']
}

## instanciate the workflowengine,
## create the workflow, and save it
## run the workflow
wfe = Wfe::Engine.new(db_conf, opts)



begin
  if ARGV[0] == 'create'
    wf = wfe.create_workflow(
        ARGV[1],
        init_time_ctx,
        step_sequence,
    )
  elsif ARGV[0] == 'execute'
    wfe.run(ARGV[1])
  end


rescue Mmc::Exception=>e
  puts e.to_s
  puts "not sure what to do"
rescue Mmc::WorkflowEngineHalted=>e
  puts e.to_s
  puts "workflow halted!"
rescue Mmc::WorkflowEngineStepError=>e
  puts "step error: %s" % [e.to_s]
rescue Mmc::WorkflowLockedException=>e
  puts e.to_s
  puts "workflow locked"
rescue Mmc::WorkflowEngineErrorState=>e
  puts "workflow in error state: %s" % [e.to_s]
end

#wfe.run
     #.each { |s| puts s.to_s }

