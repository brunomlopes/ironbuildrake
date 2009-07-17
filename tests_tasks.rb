require 'rubygems'
require 'build_engine'
require 'fileutils'
require 'test/unit'
require 'mocha'
require 'pathname'

module MSTaskTestUtil
  def mstask_for_engine(build_engine)
    modules = [Microsoft::Build::Tasks]
    MSTask.new(modules, build_engine)
  end
end

class Message < Test::Unit::TestCase
  include MSTaskTestUtil
  
  def test_send_event_to_build_engine
    build_engine = RubyBuildEngine.new
    build_engine.expects(:log_message_event)

    msbuild = mstask_for_engine(build_engine)
    msbuild.Message :text => "Text"
  end
end

class Delete < Test::Unit::TestCase
  include MSTaskTestUtil



  def test_delete_task_deletes_file
    build_engine = RubyBuildEngine.new
    msbuild = mstask_for_engine(build_engine)

    filename = random_filepath()
    FileUtils.touch filename
    msbuild.Delete :files => filename

    assert !File.exists?(filename)
  end

  def test_delete_task_deletes_two_files
    build_engine = RubyBuildEngine.new
    msbuild = mstask_for_engine(build_engine)

    filenames = Array.new(2) {random_filepath()}
    filenames.each { |filename| FileUtils.touch filename }
    msbuild.Delete :files => filenames

    filenames.each { |filename| !File.exists?(filename) }
  end

  def setup
    @@directory = "temp"
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
    chars = ("a".."z").to_a + ("1".."9").to_a
    filename = Array.new(8, '').collect{chars[rand(chars.size)]}.join
    return (Pathname.new(@@directory)+filename).to_s
  end
end
