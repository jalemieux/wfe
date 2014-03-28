require "wfe"

# stops a fictious app, gathers stopped servers
class StopAppX < Wfe::BaseStep
 def work(ctx)
    raise Exception.new("cannot find the servers in the context!") if ctx[:target_servers].nil?
    stopped_servers = []
    ctx[:target_servers].each do |s|
      print "i'm stopping server %s!\n" % [s]
       stopped_servers << s if stop_server s
     end
     # store the servers that were actually stopped for later use
     ctx[:stop_servers] = stop_servers
     sleep 2
 end
 def stopped_servers(server)
    # dummy call always return true
    true
 end
end

# execute a shell command, raises an exception (halting the workflow) on failure
class RunShell < Wfe::BaseStep
 def work(ctx)
   raise Exception.new("cannot find the maintenance cmd in the context!") if ctx[:maint_cmd].nil?
   ctx[:stopped_servers].each do |s|
      print "Running the maintenance on %s!\n" % [s]
      # abort the workflow execution if a command is not run successfully
      raise Exception.new("cmd failed!") unless system(ctx[:maint_cmd])
    end
 end
end
# restart the servers that were stopped
class StartAppX < Wfe::BaseStep
 def work(ctx)
   raise Exception.new("cannot find the servers to restart in the context!") if ctx[:stopped_servers].nil?
   ctx[:stopped_servers].each do |s|
        restart server s
       print "restarting server %s !\n" % [s]
   end
 end
end


s1 = StartAppX.new
s2 = StopAppX.new
s3 = RunShell.new