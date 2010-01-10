require 'log'
require 'task_item'
require 'assembly_loader'
require 'namespace_node'

class TaskLibrary
  attr_reader :tasks

  def self.from_modules(build_engine, *modules)
    tasks = self.tasks_in_modules(modules)
    return TaskLibrary.new(build_engine, tasks)
  end

  def self.from_tasks_file(build_engine, task_file_path)
    targets = TasksFile.from_file(task_file_path)
    targets.load_assemblies()

    tasks = targets.task_class_names.map do |class_name|
      begin
        ruby_class_name = class_name.gsub(/\./,"::")
        eval(ruby_class_name)
      rescue NameError
        puts "Error loading task class #{ruby_class_name}"
      end
    end
    tasks = tasks.delete_if{ |task| task == nil}
    return TaskLibrary.new(build_engine, tasks)
  end

  def initialize(build_engine, tasks)
    @root_namespace = NamespaceNode.new("")
    @tasks = tasks
    @logger = $logger

    namespaces = Set.new(@tasks.map{ |cls| cls.to_clr_type.namespace })

    namespaces.each do |namespace|
      next if namespace.strip.size == 0

      split_namespaces = String.new(namespace).split(".")
      define_root_namespace_method(split_namespaces[0])

      node = @root_namespace
      while split_namespaces.size > 0
        node = node.add_child(split_namespaces.shift)
      end
    end

    @tasks.each do |cls|
      method_name = cls.to_clr_type.name.to_sym
      task_namespace = cls.to_clr_type.namespace.split(".")
      define_execute_method(method_name, build_engine, cls)
      @root_namespace.add_object(method_name, lambda {|args| execute_method(build_engine, cls, args) }, *task_namespace)
    end
  end

  def define_root_namespace_method(namespace)
    self.metaclass.send :define_method, namespace do
      @root_namespace.send namespace
    end
  end

  def define_execute_method(method_name, build_engine, cls)
    self.metaclass.send :define_method, method_name do |args|
      execute_method(build_engine, cls, args)
    end
  end

  def execute_method(build_engine, cls, args)

    args ||= {}
    instance = cls.new
    instance.BuildEngine = build_engine

    @logger.debug("execute_method for #{cls} with #{args.inspect}")

    properties = instance.class.to_clr_type.get_properties

    args.each_pair do |k, v|
      property = properties.find {|prop| prop.name.downcase == k.to_s.downcase}
      if property != nil
        value = value_for_property(property, v)
        @logger.debug("execute_method #{property} -> #{value.inspect}")
        property.set_value(instance, value, nil)
      else
        @logger.warn("Property #{k} not found in #{cls}")
      end
    end
    result = instance.Execute
    @logger.debug("result: "+result.to_s)
  end

  def value_for_property(property, original_value)
    arrayOfStrings = System::Array.of(System::String)
    arrayOfITaskItems = System::Array.of(Microsoft::Build::Framework::ITaskItem)

    value = original_value
    # try and figure out what kind of value the property will accept
    # and adapt the value given to it
    if property.property_type.is_array
      if not value.kind_of?(Array)
        value = [value]
      end
      if property.property_type == arrayOfStrings.to_clr_type
        value = arrayOfStrings.new(value.map{ |v| v.to_s.to_clr_string })
      elsif property.property_type == arrayOfITaskItems.to_clr_type
        value = arrayOfITaskItems.new(value.map{ |v| TaskItem.new(v) })
      else
        raise "Property type #{property.property_type} is not handled"
      end
    else
      if property.property_type == System::String.to_clr_type
        value = value.to_s.to_clr_string
      elsif property.property_type == Microsoft::Build::Framework::ITaskItem
        value = TaskItem.new(value)
      else
        raise "Property type #{property.property_type} is not handled"
      end
    end
    return value
  end

  def to_s()
    return "Library with {@tasks.size} tasks"
  end

  def self.tasks_in_modules(modules)
    itask_interface = Microsoft::Build::Framework::ITask.to_clr_type
    tasks = []
    modules.each do |mod|
      classes = mod.constants.map { |c| mod.class_eval(c) }
      classes = classes.select do |cls|
        if !cls.respond_to?(:to_clr_type) || !cls.to_clr_type.respond_to?(:get_interfaces)
          interfaces = []
        else
          interfaces = cls.to_clr_type.get_interfaces
        end
        interfaces.include?(itask_interface)
      end
      tasks.concat(classes)
    end
    return tasks
  end

  def metaclass
    class << self
      self
    end
  end
end
