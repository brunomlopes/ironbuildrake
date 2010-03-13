require 'rubygems'
require 'build_engine'
require 'fileutils'
require 'test/unit'
require 'mocha'
require 'pathname'
require 'stringio'
require 'helper'
require 'enumerator'

module MSTaskTestUtil
  def mstask_for_engine(build_engine)
    TaskLibrary.from_modules(build_engine, Microsoft::Build::Tasks)
  end

  def default_ruby_build_engine()
    @output = StringIO.new
    @output_logger = Logger.new(@output)
    return RubyBuildEngine.new(@output_logger)
  end
  def mstask_library()
    mstask_for_engine(default_ruby_build_engine())
  end
end

class Message < Test::Unit::TestCase
  include MSTaskTestUtil

  def test_send_event_to_build_engine
    build_engine = default_ruby_build_engine()
    build_engine.expects(:log_message_event)

    msbuild = mstask_for_engine(build_engine)
    msbuild.Message :text => "Text"
  end

  def test_message_appears_on_output
    msbuild = mstask_for_engine(default_ruby_build_engine())
    desired_text = "This is the text we'll be looking for"
    msbuild.Message :text => desired_text
    assert_not_nil(Regexp.new(desired_text).match(@output.string),
                   "Text not found in output")
  end
end

class CommonMsbuildTasksAreLoaded < Test::Unit::TestCase
  include MSTaskTestUtil

  def test_delete
    library = mstask_library()
    assert_respond_to library , :Delete
  end

  def test_message
    library = mstask_library()
    assert_respond_to library , :Message
  end
end


class Delete < Test::Unit::TestCase
  include MSTaskTestUtil

  def test_delete_task_deletes_file
    build_engine = default_ruby_build_engine()
    msbuild = mstask_for_engine(build_engine)

    filename = random_filepath()
    FileUtils.touch filename
    msbuild.Delete :files => filename

    assert !File.exists?(filename)
  end

  def test_delete_task_deletes_two_files
    build_engine = default_ruby_build_engine()
    msbuild = mstask_for_engine(build_engine)

    filenames = [random_filepath(), random_filepath()]
    filenames.each { |filename| FileUtils.touch filename }
    msbuild.Delete :files => filenames

    filenames.each { |filename| !File.exists?(filename) }
  end

  def setup
    @@directory = "temp"
    @@r = System::Random.new
    clean_and_remove_directory()
    Dir.mkdir(@@directory)
  end

  def teardown
    clean_and_remove_directory()
  end

  def clean_and_remove_directory()
    if File.exists?(@@directory) and File.directory?(@@directory)
      FileUtils.remove_dir(@@directory)
    end
  end


  def random_filepath
    number_of_random_chars = 8
    s = @@directory+"/"
    number_of_random_chars.times { s << (65 + @@r.Next(26)) }
    s
  end
end

class OutputParameters < Test::Unit::TestCase
  include MSTaskTestUtil

  def test_output_parameter_is_returned_in_dictionary
    build_engine = default_ruby_build_engine()
    msbuild = mstask_for_engine(build_engine)

    values = msbuild.FindUnderPath({ :path => "..\\", :files=>"Rakefile"})
    assert(values.has_key?("InPath"))
    assert(values["InPath"].any? { |v| v.item_spec == "Rakefile"})
  end

  def test_input_parameter_is_not_returned_in_dictionary
    build_engine = default_ruby_build_engine()
    msbuild = mstask_for_engine(build_engine)

    values = msbuild.FindUnderPath({ :path => "..\\", :files=>"Rakefile"})
    assert(!values.has_key?("Files"))
  end
end

class Parameters < Test::Unit::TestCase
  include MSTaskTestUtil

  def test_can_assign_boolean_to_value
    build_engine = default_ruby_build_engine()
    msbuild = mstask_for_engine(build_engine)

    msbuild.Touch({ :AlwaysCreate => false, :Files => ["tests_tasks.rb"]})
  end
end

# task :test_scenario_1 do
#   msbuild = tasks_from_module(Microsoft::Build::Tasks)
#   # this should make the task fail the rake build if has error.

#   msbuild.Warning({ :text => "This is a text message" }).fail_on_error

#   # or perhaps the best way would be for it to be reversed
#   msbuild.Warning({ :text => "This is a text message" }).proceed_on_error

# end


class TasksFromTargetFile  < Test::Unit::TestCase
  include MSTaskTestUtil


  def test_tasks_from_3_5_targets
    directory = System::Environment.expand_environment_variables('%WINDIR%\Microsoft.NET\Framework\v3.5')
    file_name = "Microsoft.Common.Tasks"
    full_path = System::IO::Path.combine(directory, file_name)
    build_engine = default_ruby_build_engine()

    task_library = TaskLibrary.from_tasks_file(build_engine, full_path)
    assert(task_library.respond_to?(:AssignProjectConfiguration),
           "Task library should have 'AssignAssignProjectConfiguration' task")

  end
end

