require 'build_engine'

require 'test/unit'
require 'mocha'


class MSTaskTest < Test::Unit::TestCase
  
  def mstask_for_engine(buildEngine)
    modules = [Microsoft::Build::Tasks]
    MSTask.new(modules, buildEngine)
  end
  
  def test_message_sends_event
    buildEngine = RubyBuildEngine.new
    buildEngine.expects(:log_message_event)

    msbuild = mstask_for_engine(buildEngine)
    msbuild.Message :text => "Text"
  end

end
