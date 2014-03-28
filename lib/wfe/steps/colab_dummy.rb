# dummy class use in test and examples
class Wfe::Steps::ColabDummy < Wfe::BaseStep
  def work(ctx)
    raise Exception.new("counter not found!") if ctx[:counter].nil?
    puts "counter: " + ctx[:counter].to_s
    ctx[:counter] =  ctx[:counter] + 1
  end
end