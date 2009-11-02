class NamespaceNode
  attr_reader :name, :children
  def initialize(name)
    @name = name
    @children = { }
    @objects = { }
  end

  def << (name)
    add_child(name)
  end

  def add_child(name)
    if @objects.has_key? name
      raise Exception.new("Node #{@name} already has object with name #{name}")
    end
    if not @children.has_key? name
      @children[name] = NamespaceNode.new(name)
      self.metaclass.send :define_method, name do
        @children[name]
      end
    end
    @children[name]
  end

  def add_object(name, object, *namespaces)
    raise Exception.new("Node #{@name} already has child node with name #{name}") if @children.has_key? name
    raise Exception.new("Node #{@name} already has object with name #{name}") if @objects.has_key? name

    if namespaces.length > 0
      next_namespace = namespaces.shift.to_s
      raise Exception.new("No namespace with name #{next_namespace} found") if not @children.has_key?(next_namespace)
      @children[next_namespace].add_object(name, object, *namespaces)
    else
      @objects[name] = object
      self.metaclass.send :define_method, name do
        @objects[name]
      end
    end
    
    self
  end

  def metaclass
    class << self
      self
    end
  end
end
