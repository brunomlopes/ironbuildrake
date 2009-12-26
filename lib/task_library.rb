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

    properties = instance.class.to_clr_type.get_properties

    args.each_pair do |k, v|
      property = properties.find {|prop| prop.name.downcase == k.to_s.downcase}
      if property == nil
        return
      end
      value = value_for_property(property, v)

      property.set_value(instance, value, nil)
    end
    instance.Execute
  end

  def value_for_property(property, original_value)
    itaskitem = Microsoft::Build::Framework::ITaskItem
    value = original_value
    if value.kind_of?(Array)
      value = System::Array.of(itaskitem).new(original_value.map{|item| TaskItem.new(item)})
    elsif value.kind_of?(String)
      return_type_name = property.get_get_method.return_type.full_name
      if return_type_name == "System.String"
        value = value.to_clr_string
      else
        value = System::Array.of(itaskitem).new([value].map{|item| TaskItem.new(item)})
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
