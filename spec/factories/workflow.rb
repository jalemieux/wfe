require 'wfe'

FactoryGirl.define do
  factory :workflow, class: Wfe::Workflow do
    name "test_workflow"
    init_time_ctx {}
    run_time_ctx {}
    scheduled Time.now
    start Time.now
    created_at Time.now
    state Wfe::Workflow::STATE_PENDING

    factory :workflow_dummy do
      after(:create) do |workflow|
        FactoryGirl.create_list(:workflowstep,5, workflow: workflow )
      end
    end

    factory :workflow_bad do
      after(:create) do |workflow|
        FactoryGirl.create_list(:workflowstep,2,workflow: workflow, impl_class: Wfe::Steps::Dummy.to_s)
        FactoryGirl.create(:workflowstep,workflow: workflow, impl_class: Wfe::Steps::Error.to_s)
        FactoryGirl.create_list(:workflowstep,2,workflow: workflow, impl_class: Wfe::Steps::Dummy.to_s)
      end
    end

    factory :workflow_good do
      after(:create) do |workflow|
        FactoryGirl.create_list(:workflowstep,5,workflow: workflow, impl_class: Wfe::Steps::Dummy.to_s)
      end
    end

    factory :workflow_colab do
      after(:create) do |workflow|
        FactoryGirl.create_list(:workflowstep,5,workflow: workflow, impl_class: Wfe::Steps::ColabDummy.to_s)
      end
    end

    #factory :workflow_with_steps do
    #  ignore do
    #    step_count 5
    #  end
    #
    #  after(:create) do |workflow,evaluator|
    #    FactoryGirl.create_list(:workflowstep, evaluator.step_count, workflow: workflow)
    #  end
    #end

  end
end
=begin
wf = Wfe::Workflow.create(
    :name => "test_workflow",
    :init_time_ctx => {},
    :run_time_ctx => {},
    :scheduled => Time.now,
    :state => Wfe::Workflow::STATE_PENDING,
    :created_at => Time.now
)
(1..5).each do |n|
  step = Wfe::WorkflowStep.create(
      :name => "%d-%s-%s" % [n =+ 1 ,'test_workflow', 'dummy_class'],
      :impl_class => 'dummy_class',
      :args => [],
      :state => Wfe::WorkflowStep::STATE_PENDING
  )
  wf.steps << step
=end