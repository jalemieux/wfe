# WorkflowStep extends ActiveRecord::Base and is used to define and store a workflow's steps
#
# Author::    jacques@marketo.com
#
class Wfe::WorkflowStep < ActiveRecord::Base
  self.table_name = 'workflow_step'
  serialize :args
  belongs_to :workflow , :class_name => "Workflow",
             :foreign_key => "workflow_id"
  #indicates the step has not yet been ran.
  STATE_PENDING = 'pending'
  # indicates the step has started, which means its currently running , or the workflow process exited ungracefully.
  STATE_STARTED = 'started'
  # indicates the step ran into a failure condition.
  STATE_ERROR = 'error'
  # indicates the step ran successfully.
  STATE_COMPLETED = 'completed'

  # a Wfe::WorkflowStep has an attribute called 'impl_class' which indicates which class
  # implements the steps. An object of this class should be instantiated so that the Wfe::Engine
  # can call its 'work' method.
  # step_instance_opts is a hash containing configuration information for the step instance,
  # e.g. logger, redirect, etc. See Wfe::BaseStep for details
  def run(runtime_ctx, step_instance_opts)
    clazz = eval(impl_class)
    raise WorkflowEngineException.new("step class %s is not defined as a class" % [impl_class]) unless clazz.is_a?(Class)
    instance = clazz.new(step_instance_opts, args)
    instance._work(runtime_ctx)
  end

end
