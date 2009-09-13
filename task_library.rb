require 'task_item'
require 'assembly_loader'


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
    @tasks = tasks
    @tasks.each do |cls|
      method_name = cls.to_clr_type.name.to_sym
      self.metaclass.send :define_method, method_name do |args|
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
    end
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
