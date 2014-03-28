require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:rspec) do |s|
  s.rspec_opts = '-f d -c '
  s.pattern = 'spec/*_spec.rb'
end



