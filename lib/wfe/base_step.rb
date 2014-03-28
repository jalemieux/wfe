# Abstract Base Step of a Workflow
#
# Author::    jacques@marketo.com
# Copyright:: Copyright (c) marketo inc.
#
# ==== Description
# Steps forming a workflow should be implemented via classes
# extending Wfe::BaseStep.
# Steps classes should implement the 'work' method.
#
# ==== Usage Example
#
#   class StopApp < Wfe::BaseStep
#     def work(ctx)
#       raise Exception.new("cannot find the servers in the context!") if ctx[:target_servers].nil?
#       ctx[:target_servers].each { |s| print "i'm stopping server %s!\n" % [s]  }
#       sleep 2
#     end
#   end
#
#
class Wfe::BaseStep
  attr_accessor :output_redirect
  attr_accessor :logger

  def initialize(step_instance_opts, args = [])
    parse_options(step_instance_opts)
    @args = args # currently not used
  end

  def parse_options(opts)
    @logger = opts[:logger] || nil
    @output_redirect_lambda = opts[:redirect] || nil
  end
  # this is called by WorkflowStep
  # here you could add pre and post step hooks
  def _work(context)
    # pre step hook
    ret = work(context)
    # post step hook
    ret
  end

  # override puts io method
  def puts (obj)
    #STDOUT.puts @output_redirect_lambda.inspect
    if @output_redirect_lambda.nil?
      STDOUT.print obj.to_s + "\n"
    else
      @output_redirect_lambda.call obj unless @output_redirect_lambda.nil?
    end
  end


  # will be called by the workflow engine
  # context is a hash like object containing
  # the workflow run time context
  def work(context)
    raise NotImplementedError.new
  end
end
