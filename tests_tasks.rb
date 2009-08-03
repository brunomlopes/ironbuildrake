require 'rubygems'
require 'build_engine'
require 'fileutils'
require 'test/unit'
require 'mocha'
require 'pathname'
require 'stringio'


module MSTaskTestUtil
  def mstask_for_engine(build_engine)
    TaskLibrary.from_modules(build_engine, Microsoft::Build::Tasks)
  end

  def default_ruby_build_engine()
    @output = StringIO.new
    @output_logger = Logger.new(@output)
    return RubyBuildEngine.new(@output_logger)
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
    s = ""
    number_of_random_chars.times { s << (65 + @@r.Next(26)) }
    s
  end
end

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

