require 'wfe'

FactoryGirl.define do
  factory :workflowstep, class: Wfe::WorkflowStep do
    sequence(:name, 1) { |n| "test_step_#{n}" }
    impl_class "some class"
    args []
    state Wfe::WorkflowStep::STATE_PENDING
    association :workflow, factory: :workflow , strategy: :build
  end
end