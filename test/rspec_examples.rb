require 'wfe'
require 'logger'

# workflow engine options
opts = {
    :logger => Logger.new("/var/log/mktoutils/test.log"),
}
# datasource configs

module WorkflowEngine
  describe Wfe::Engine, " A new Instance " do
    let(:db_conf) {
      { :adapter  => "mysql2",
        :host     => "127.0.0.1",
        :username => "root",
        :password => "unlock",
        :database => "test"
      }
    }
    let(:opts) {
      {
        :logger => Logger.new("/var/log/mktoutils/test.log"),
      }
    }
    let(:wf1) {
      wf = create(:workflow)
    }

    it "should have its attribute set correctly" do
      wfe = Wfe::Engine.new(db_conf, opts)
      wfe.logger.class.should == Logger
      wfe.db_conf.should_not == nil
    end


    it "creates and fails saving a workflow with a name that is already taken"
  end
end
