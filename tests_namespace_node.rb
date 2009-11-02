require 'rubygems'
require 'test/unit'
require 'namespace_node'

class TestNamespaceNodes < Test::Unit::TestCase
  def test_node_can_add_children
    node = NamespaceNode.new "root"
    node << "child"
    assert_respond_to node, :child
    assert_equal node.child.name, "child"
  end

  def test_node_can_add_sub_children
    node = NamespaceNode.new "root"
    node << "child" << "subchild"
    assert_respond_to node, :child
    assert_respond_to node.child, :subchild
  end

  def test_name_can_add_object
    node = NamespaceNode.new "root"
    obj = Object.new
    node.add_object("object", obj)
    assert_respond_to node, :object
    assert_equal node.object, obj
  end

  def test_add_task_to_namespace
    node = NamespaceNode.new "root"
    node << "child"
    obj = Object.new
    node.add_object("object", obj, "child")

    assert_respond_to node.child, :object
  end

  def test_add_task_to_subnamespace
    node = NamespaceNode.new "root"
    node << "child" << "subchild"
    obj = Object.new
    node.add_object("object", obj, "child", "subchild")

    assert_respond_to node.child.subchild, :object
  end
end
