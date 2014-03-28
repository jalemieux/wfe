

module Wfe
  #VERSION = "1.0.%s" % `svnversion`.match(/^\d+/).to_s
end

require 'yaml'
require 'thread'
require 'active_record'
require 'pp'
require 'wfe/base_step'
require 'wfe/lock'
require 'wfe/exceptions'
require 'wfe/engine'
require 'wfe/workflow'
require 'wfe/workflow_step'

# generic step implementations
require 'wfe/steps/steps'
require 'wfe/steps/run_on_remote_hosts'
require 'wfe/steps/dummy'
require 'wfe/steps/error'
require 'wfe/steps/colab_dummy'


