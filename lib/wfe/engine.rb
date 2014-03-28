# Engine abstract the creation and storage of Workflow and WorkflowStep(s).
#
# Author::    jacques@marketo.com
#
#
class Wfe::Engine
  attr_reader :logger
  attr_reader :db_conf

  def initialize(db_conf, opts = {})
    @logger = opts[:logger] || nil

    # intended for steps output redirection, not for engine to use,
    # but to pass to step instance
    @redirector_lambda = opts[:redirect] || nil

    @db_conf = db_conf
    @wf = nil

    # a reference to opts will be passed to step instances
    @opts = opts

    if ! ActiveRecord::Base.connected?
      obj = ActiveRecord::Base.establish_connection(
          :adapter  => @db_conf[:adapter],
          :host     => @db_conf[:host],
          :username => @db_conf[:username],
          :password => @db_conf[:password],
          :database => @db_conf[:database]
      )
    end
  end



  # saves workflow and steps and context to db.
  # The argument 'name' must be unique, as the work flow engines does not support 2 or more workflow with the same name,
  # it will raise a Wfe::Exception if it founds another workflow named 'wf_name'
  def create_workflow(wf_name, init_time_ctx, step_classes)
    # raise an exception if the workflow already exists
    raise Wfe::Exception.new("workflow %s already exists" % [wf_name]) if Wfe::Workflow.exists?({ :name => wf_name})

    n = 0
    ActiveRecord::Base.transaction do
      w = Wfe::Workflow.create(
          :name => wf_name,
          :init_time_ctx => init_time_ctx,
          :run_time_ctx => init_time_ctx,
          :scheduled => Time.now,
          :state => Wfe::Workflow::STATE_PENDING,
          :created_at => Time.now
      )
      step_classes.each do |clazz|
        clazz = clazz.to_s if clazz.is_a?(Class)
        w.steps.create(
            :name => "%d-%s-%s" % [n =+ 1 ,wf_name, clazz],
            :impl_class => clazz,
            :args => [],
            :state => Wfe::WorkflowStep::STATE_PENDING
        )
      end
      w.save
    end
  end

  # THe argument 'wf_name' should be matching the name of a workflow that was previously saves to the DB.
  # @see create_workflow
  #
  # Raises Wfe::Exception if wf_name cannot be found in db
  # Raises Wfe::WorkflowLocked if another process has not release the lock on 'wf_name'
  # Raises  Wfe::ErrorState if any step of the work flow is in started or error state, this prevents resuming workflows
  # that have run into a failure that was not addressed
  # Raises Wfe::StepError if a steps raises an exception - i.e. if a step runs into any problem and cannot complete its
  # work
  # TODO: clear up db lock on return (success or failure)
  def run(wf_name)
    # make sure the workflow has been previously creted and save in the database
    raise Wfe::WorkflowMIA.new("workflow %s not found" % [wf_name]) unless Wfe::Workflow.exists?({ :name => wf_name})

    # using the sempahore to 'lock' this workflow. Note that the workflow is
    # not really 'locked', we assume the Semaphore is used correctly
    # to insure only one process writes updates to a single workflow instance at any time
    # lock duration is arbitrary, but should be long enough not to be cleaned up by mistake
    lock_duration = 60*60*24*30
    # raise and exception if the semaphore already exists, could be a left over from
    # a previously dead process or a running one
    raise Wfe::WorkflowLocked.new("workflow %s is locked" % [wf_name]) unless Wfe::Lock.acquire?(wf_name,lock_duration)

    wf = nil

    # mark the workflow as started!
    @wf = Wfe::Workflow.find_by_name(wf_name)

    # collect the state of each steps, and raise exception if the workflow is not
    # in a state where it can be executed
    steps_to_run = []
    @wf.steps.each do |s|
      # a step that has previously been put to 'error' indicates the workflow cannot be executed in its current state
      # a step that a step in 'started' state indicates that the workflow is being run  - something that shouldnt happen
      # if the Semaphore earlier work - or some problem with a previous process, e.g. someone kill -9 the ruby process
      # executing the worlkflow
      if s.state == Wfe::WorkflowStep::STATE_ERROR or s.state == Wfe::WorkflowStep::STATE_STARTED
        Wfe::Lock.release(wf_name)
        raise Wfe::ErrorState.new("a step is in %s state: %s" %[s.state, s.name])
      end
      if s.state == Wfe::WorkflowStep::STATE_PENDING
        steps_to_run << s
      end
    end
    if steps_to_run.empty?
      # no step in 'pending' state, hence consider the workflow completed
      Wfe::Lock.release(wf_name)
      return true
    end

    log("starting execution on workflow %s" % [@wf.name], Logger::INFO)
    @wf.state = Wfe::Workflow::STATE_STARTED
    @wf.save

    steps_to_run.each do |step|
      log("executing step %s" % [step.name], Logger::INFO)
      begin
        # execute impl_class
        # TODO: figure out context
        step.run(self, @opts)
        # mark step as completed. The step should throw an exception if a problem occurs
        Wfe::WorkflowStep.transaction do
          step.state = Wfe::WorkflowStep::STATE_COMPLETED
          step.save
        end
        log("completed step %s" % [step.name], Logger::INFO)
      rescue Exception=>e
        log_exception("caught exception while executing step %s" % [step.name], e)
        Wfe::WorkflowStep.transaction do
          step.state = Wfe::WorkflowStep::STATE_ERROR
          step.save
          step.workflow.state = Wfe::Workflow::STATE_ERROR
          step.workflow.save
        end
        # release the lock, so the workflow can be resumed alter on
        Wfe::Lock.release(wf_name)
        raise Wfe::StepError.new(e)
      end
    end
    @wf.state = Wfe::Workflow::STATE_COMPLETED
    @wf.save
    log("completed workflow %s" % [@wf.name], Logger::INFO)
    Wfe::Lock.release(wf_name)
    return true
  end

  # helper function to format and log exceptions,
  # DRY
  def log_exception(msg, e)
    @logger.log(Logger::ERROR, msg) unless @logger.nil?
    @logger.log(Logger::ERROR, e) unless @logger.nil?
  end

  # encapsulate call to logger, for cases when logger is not set (nil)
  # DRY
  def log(msg,level = Logger::DEBUG)
    @logger.log(level, msg) unless @logger.nil?
  end

  # returns workflow context variables (workitems in Ruote)
  # this should not be accessed outside of the instance
  def [](key)
    raise Wfe::Exception.new("workflow context hash accessed outside of execution scope") unless ! @wf.nil?
    return @wf.run_time_ctx[key]
  end
  # sets workflow context variables (workitems in Ruote)
  def []=(key,value)
    raise Wfe::Exception.new("workflow context hash accessed outside of execution scope") unless ! @wf.nil?
    @wf.run_time_ctx[key] = value
    @wf.save
  end


end


