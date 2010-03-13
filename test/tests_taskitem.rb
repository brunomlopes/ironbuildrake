require 'rubygems'
require 'build_engine'
require 'fileutils'
require 'test/unit'
require 'mocha'
require 'pathname'
require 'stringio'
require 'helper'
require 'enumerator'
require 'task_item'

class TaskItemTest < Test::Unit::TestCase
  def test_task_item_is_equal_to_string
    assert TaskItem.new("Text") == "Text"
  end

  def test_task_item_is_different_to_different_string
    assert TaskItem.new("Text") != "Another Test"
  end

  def test_task_item_is_equal_to_another_TaskItem_with_same_text
    assert TaskItem.new("Text") == TaskItem.new("Text")
  end
end
