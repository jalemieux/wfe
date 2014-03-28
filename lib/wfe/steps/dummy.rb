
# dummy step use in test and examples
class Wfe::Steps::Dummy < Wfe::BaseStep
  MESSAGE = "not doing anything really!"
  def work(ctx)
    #puts "i wish nothing"
    puts MESSAGE
  end
end