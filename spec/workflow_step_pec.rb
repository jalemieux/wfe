require 'wfe'
require 'logger'
require 'spec_helper'



#FactoryGirl.find_definitions
#wf = FactoryGirl.create(:workflow)
#puts wf.inspect
#exit 1
#config.include FactoryGirl::Syntax::Methods


module WorkflowEngine
  describe Wfe::Engine, "" do
    let(:opts) {
      {
          :logger => Logger.new("/var/log/mktoutils/test.log"),
      }
    }

    before :each do
      # dont use this workflow for execution testing, the classes are dummies.
      @dummy_wf = FactoryGirl.create(:workflow_dummy, name: 'dummy_test_workflow')
      @bad_wf = FactoryGirl.create(:workflow_bad, name: 'bad_test_workflow')
      @good_wf = FactoryGirl.create(:workflow_good, name: 'good_test_workflow')

=begin
      @dummy_wf = FactoryGirl.create(:workflow, name: 'dummy_test_workflow') do |wf|
        (1..5).each do |n|
          step_name = 'test_step_%d' % [n]
          #wf.steps << FactoryGirl.create(:workflowstep, name: step_name, workflow: @dummy_wf)
        end
      end
      # use this workflow to test execution failure.
      @bad_wf = FactoryGirl.build(:workflow, name: 'bad_test_workflow') do |wf|
        (1..5).each do |n|
          # insert a step that throws an exeception. Useful for negative testing.
          if (n == 3)
            wf.steps << FactoryGirl.build(:workflowstep, name: 'problem step', impl_class: Wfe::Steps::Error, workflow: @bad_wf)
            next
          end
          step_name = 'test_step_%d' % [n]
          wf.steps << FactoryGirl.build(:workflowstep, name: step_name, impl_class: Wfe::Steps::Dummy, workflow: @bad_wf)
        end
      end
      @good_wf = FactoryGirl.build(:workflow, name: 'bad_test_workflow') do |wf|
        (1..5).each do |n|
          # insert a step that throws an exeception. Useful for negative testing.
          step_name = 'test_step_%d' % [n]
          wf.steps << FactoryGirl.build(:workflowstep, name: step_name, impl_class: Wfe::Steps::Dummy, workflow: @good_wf)
        end
      end
=end
    end

    describe "Workflow Creation" do
      it "fails on creation when the name is already taken" do
        puts "Some data: " + Wfe::Workflow.find_by_name('dummy_test_workflow').to_s
        wfe = Wfe::Engine.new($db_conf, opts)
        expect { wfe.create_workflow('dummy_test_workflow', {}, []) }.to raise_error(Wfe::Exception)
      end
    end


    describe "Workflow Execution:" do
     it "halts on step error" do
       wfe = Wfe::Engine.new($db_conf, opts)
       expect { wfe.run('bad_test_workflow') }.to raise_error(Wfe::StepError)
     end
    end

    it "completes with the right states"
    it "keeps track of the start and end"

  end
end
