require 'rubygems'
require 'build_engine'
require 'fileutils'
require 'test/unit'
require 'mocha'
require 'pathname'
require 'stringio'
require 'helper'

module TaskLibraryMixin
  def build_engine
    @output = StringIO.new
    @output = STDOUT
    @output_logger = Logger.new(@output)
    return RubyBuildEngine.new(@output_logger)
  end

  def task_library
    TaskLibrary.from_tasks_file(build_engine, @tasks_file)
  end

  def assert_has_task (task)
    assert_respond_to task_library, task
  end
end

class MSBuildCommunityTasks < Test::Unit::TestCase
  include TaskLibraryMixin

  def test_loads_assembly_info_task
    assert_has_task :AssemblyInfo
  end

  def test_loads_vss_get_task
    assert_has_task :VssGet
  end

  def setup
    @tasks_file = "test/test-libraries/MSBuildCommunityTasks/MSBuild.Community.Tasks.Targets"
  end
end

class SBF #< Test::Unit::TestCase
  include TaskLibraryMixin

  def test_loads_biztak_2002_configure_task
    assert_has_task :Configure
  end

  def setup
    @tasks_file = "test/test-libraries/sbf/Microsoft.Sdc.Common.tasks"
  end
end
