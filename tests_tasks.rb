require 'rubygems'
require 'build_engine'
require 'fileutils'
require 'test/unit'
require 'mocha'
require 'pathname'
require 'stringio'


module MSTaskTestUtil
  def mstask_for_engine(build_engine)
    modules = [Microsoft::Build::Tasks]
    MSTask.new(modules, build_engine)
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
    puts @output.string
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

