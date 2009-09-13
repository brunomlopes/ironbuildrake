require 'rubygems'
require 'test/unit'
require 'mocha'
require 'task_library'

module TestNamespace
  class TestTask
  end
end

class TaskLibraryNamespaces < Test::Unit::TestCase
  class MockClass
    class ClrType
      attr_reader :name
      def initialize(name)
        @name = name
      end
    end
    def initialize(name)
      @name = name
    end
    def to_clr_type
      ClrType.new @name
    end
  end

  def test_task_in_namespace
    tasks = [MockClass.new "test"]
    library = TaskLibrary.new(create_mock_engine, tasks)
    assert_respond_to library, :test
  end

  def test_different_libraries_should_have_different_tasks
    tasks = [MockClass.new "first"]
    TaskLibrary.new(create_mock_engine, tasks)

    tasks = [MockClass.new "second"]
    second_library = TaskLibrary.new(create_mock_engine, tasks)
    assert_does_not_respond_to second_library, :first
    assert_respond_to second_library, :second
  end

  def create_mock_engine
    mock()
  end


  def assert_does_not_respond_to(object, method, message="")
    full_message = build_message(nil, "<?>\ngiven as the method name argument to #assert_respond_to must be a Symbol or #respond_to\\?(:to_str).", method)

    assert_block(full_message) do
      method.kind_of?(Symbol) || method.respond_to?(:to_str)
    end
    full_message = build_message(message, "<?>\nof type <?>\n expected to not respond_to\\\\?<?>.\n", object, object.class, method)
    assert_block(full_message) { not object.respond_to?(method) }
  end

end
