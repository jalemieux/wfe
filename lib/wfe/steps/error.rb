
# runs a command via ssh on a set of hostnames
class Wfe::Steps::Error < Wfe::BaseStep
  def work(ctx)
    raise Exception.new("I have no idea what i am doing")
  end
end