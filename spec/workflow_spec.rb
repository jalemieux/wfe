require 'logger'
require 'spec_helper'



#FactoryGirl.find_definitions
#wf = FactoryGirl.create(:workflow)
#puts wf.inspect
#exit 1
#config.include FactoryGirl::Syntax::Methods


module WorkflowEngine
  class Dummy < Wfe::BaseStep
    def work(ctx)
      # ok
    end
  end

  class ColabDummy < Wfe::BaseStep
    def work(ctx)
      raise Exception.new("counter not found!") if ctx[:counter].nil?
      puts "counter: " + ctx[:counter].to_s
      ctx[:counter] =  ctx[:counter] + 1
    end
  end
  class DummySTDOUT < Wfe::BaseStep
    MESSAGE = "not doing anything really!"
    def work(ctx)
      #puts "i wish nothing"
      puts MESSAGE
    end
  end


  describe Wfe::Engine, "" do
    let(:opts) {{ :logger => Logger.new("/var/log/mktoutils/test.log"), }}
    let(:dummy_file) { File.join(File.dirname(__FILE__), 'test_file.log') }

    before :each do
      # dont use this workflow for execution testing, the classes are dummies.
      @dummy_wf = FactoryGirl.create(:workflow_dummy, name: 'dummy_test_workflow')
      @bad_wf = FactoryGirl.create(:workflow_bad, name: 'bad_test_workflow')
      @good_wf = FactoryGirl.create(:workflow_good, name: 'good_test_workflow')
      @colab_wf = FactoryGirl.create(:workflow_colab, name: 'colab_test_workflow', init_time_ctx: { :counter => 0 } )

      File.open(File.join(File.dirname(__FILE__), 'test_file.log'), 'w+')
    end

    after :each do
      Wfe::Workflow.where(:name => 'dummy_test_workflow').destroy_all
      Wfe::Workflow.where(:name => 'bad_test_workflow').destroy_all
      Wfe::Workflow.where(:name => 'good_test_workflow').destroy_all
      Wfe::Workflow.where(:name => 'colab_test_workflow').destroy_all

      # remove any left over files
     File.delete(File.join(File.dirname(__FILE__), 'test_file.log'))
    end



    describe "Workflow Creation:" do
      it "should allow creation of workflow and steps" do
        wfe = Wfe::Engine.new($db_conf, opts)
        wfe.create_workflow('testing_creation', { :greeting => "hi there sir." }, [ DummySTDOUT, DummySTDOUT])
        new_wfe = Wfe::Workflow.find_by_name('testing_creation')
        new_wfe.steps do | step |
          step.impl_class.should == 'Wfe::Step::Dummy'
        end
        new_wfe.destroy
      end

      it "should set the run time context with init run time context values after creation" do
        wfe = Wfe::Engine.new($db_conf, opts)
        wfe.create_workflow('testing_context_init', { :greeting => "hi there sir." }, [ DummySTDOUT, DummySTDOUT])
        new_wfe = Wfe::Workflow.find_by_name('testing_context_init')
        new_wfe.run_time_ctx.should ==  { :greeting => "hi there sir." }
        new_wfe.destroy
      end



      it "should fail on creation when the name is already taken" do
        wfe = Wfe::Engine.new($db_conf, opts)
        expect { wfe.create_workflow('dummy_test_workflow', {}, []) }.to raise_error(Wfe::Exception)
      end
    end


    describe "Workflow Execution:" do
     it "should pause on  step error" do
       wfe = Wfe::Engine.new($db_conf, opts)
       expect { wfe.run('bad_test_workflow') }.to raise_error(Wfe::StepError)
     end

    it "should set all steps in completed state when completes w/out errors" do
      wfe = Wfe::Engine.new($db_conf, opts)
      @good_wf.steps.each do |step|
        STDOUT.should_receive(:print).with(Wfe::Steps::Dummy::MESSAGE + "\n")
      end
      wfe.run('good_test_workflow')
      executed_wf = Wfe::Workflow.find_by_name('good_test_workflow')
      executed_wf.state.should == Wfe::Workflow::STATE_COMPLETED
      executed_wf.steps.each do |step|
        step.state.should == Wfe::WorkflowStep::STATE_COMPLETED
      end

    end
    it "should keeps track of the start and end"

    it "should redirect the output of steps to STDERR if set to" do
      redirector_lambda = lambda { |obj| STDERR.puts obj.to_s }
      wfe = Wfe::Engine.new($db_conf, opts.merge!({ :redirect => redirector_lambda }))
      @good_wf.steps.each do |step|
        STDERR.should_receive(:puts).with(Wfe::Steps::Dummy::MESSAGE)
      end
      wfe.run('good_test_workflow')
    end

    it "should redirect the output of steps to file if set to" do
      redirector_lambda = lambda do |obj|
        f = File.open(dummy_file,'a+')
        f.puts(obj.to_s)
        f.flush
        f.close
      end
      wfe = Wfe::Engine.new($db_conf, opts.merge!({ :redirect => redirector_lambda }))
      wfe.run('good_test_workflow')
      expected_lines = []
      @good_wf.steps.each { |step| expected_lines << Wfe::Steps::Dummy::MESSAGE + "\n" }
      puts IO.readlines(dummy_file).should ==  expected_lines
    end

    it "should allow the context to be accessible after the wf has been loaded" do

      wfe = Wfe::Engine.new($db_conf, opts)
      wfe.create_workflow('testing_context_access_1', { :var => 0 }, [ Dummy, Dummy])
      wfe.run('testing_context_access_1')
      wfe[:var].should == 0
      Wfe::Workflow.find_by_name('testing_context_access_1').destroy
    end


    it "should raise an exception if the context is accessed when no workflow is loaded" do
      wfe = Wfe::Engine.new($db_conf, opts)
      wfe.create_workflow('testing_context_access_2', { :var => 0 }, [ Dummy, Dummy])

      expect { wfe[:var] }.to raise_error (Wfe::Exception)
      Wfe::Workflow.find_by_name('testing_context_access_2').destroy
    end


    it "should allow steps to pass data to the next step" do
      wfe = Wfe::Engine.new($db_conf, opts)
      wfe.create_workflow('testing_colab_steps', { :counter => 0 }, [ ColabDummy, ColabDummy])
      wfe.run('testing_colab_steps')
      wfe[:counter].should == 2
      Wfe::Workflow.find_by_name('testing_colab_steps').destroy
    end

    it "should honor prestep hooks"

    it "should honor post step hooks"




    end
    describe "Pause Workflow" do
      it "should stop right away when issued a stop command"
      it "should stop after the current step when issued a graceful stop command"
    end
    describe "Resume Workflow" do
      it "should resume when steps are in completed or pending states"
      it "should raise an error when resuming and one of the step is in error state"
    end

  end

end
