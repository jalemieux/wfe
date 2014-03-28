
# runs a command via ssh on a set of hostnames
class Wfe::Steps::RunOnRemoteHosts < Wfe::BaseStep
  def work(ctx)
    raise Exception.new("cmd or hosts not found in context") if ctx[:cmd_to_run].nil? or ctx[:hosts].nil?
    ctx[:hosts].each do |h|
      raise Exception.new("cmd [%s] failed!"% ctx[:cmd_to_run]) unless system('echo ssh %s "%s"' % [h,ctx[:cmd_to_run]])
    end
  end
end