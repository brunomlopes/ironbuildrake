require 'Microsoft.Build.Tasks'
require 'logger'

include Microsoft

class RubyBuildEngine
  include Microsoft::Build::Framework::IBuildEngine

  def initialize(logger)
    @logger = logger
  end

  def build_project_file(project_file_name, # string
  target_names, # string[]
  global_properties, # IDictionary
  target_outputs #IDictionary
  )
    return true
  end

  def log_event(e)
    @logger.debug("#{e.Timestamp}:#{e.ThreadId}:#{e.SenderName}:#{e.Message}")
  end

  def log_custom_event(e) # CustomBuildEventArgs
    log_event(e)
    @logger.debug("Custom event: " + e.to_s)
  end

  def log_error_event(e) #BuildErrorEventArgs
    log_event(e)
    @logger.error("#{e.Code}:#{e.ColumnNumber}:#{e.EndColumnNumber}:#{e.EndLineNumber}:#{e.File}:#{e.LineNumber}:#{e.Subcategory}")
  end

  def log_message_event(e) #BuildMessageEventArgs
    log_event(e)
    # TODO: implement importance (dunno how)
    @logger.info(e.Message)
  end

  def log_warning_event(e) #BuildWarningEventArgs
    log_event(e)
    @logger.warn(e.Message)
    @logger.debug("#{e.Code}:#{e.ColumnNumber}:#{e.EndColumnNumber}:#{e.EndLineNumber}:#{e.File}:#{e.LineNumber}:#{e.Subcategory}")
  end

  def column_number_of_task_node() # void => int
    return 1
  end

  def continue_on_error() # void => bool
    return true
  end

  def line_number_of_task_node() # void => int
    return 2
  end

  def project_file_of_task_node() # void => string
    return "project file"
  end
end

class TaskItem
  include Microsoft::Build::Framework::ITaskItem
  attr_accessor :item_spec

  def initialize(str)
    @item_spec = str
    @metadata = {}
  end

  def metadata_count
    return @metadata.length
  end

  def metadata_names
    return @metadata.keys
  end

  def to_s
    return @item_spec
  end

  def get_metadata(metadata_name) # string => string
    if @metadata.has_key?(metadata_name)
      return @metadata[metadata_name]
    else
      return ""
    end
  end

  def set_metadata(metadata_name, metadata_value) # string,string => void
    @metadata[metadata_name] = metadata_value
  end

  def remove_metadata(metadata_name) # string => void
    @metadata.delete(metadata_name) if @metadata.has_key?(metadata_name)
  end

  def copy_metadata_to(destination_item) #itaskitem => void
    @metadata.each_pair do |key, value|
      original_metadata = destination_item.get_metadata(key)
      if original_metadata == nil or original_metadata == ""
        destination_item.set_metadata(key, value)
      end
    end
    original_item_spec = destination_item.get_metadata("OriginalItemSpec")
    if original_item_spec == nil or original_item_spec == ""
      destination_item.set_metadata("OriginalItemSpec", @item_spec)
    end
  end

  def clone_custom_metadata()# void => IDictionary
    return Hash.new().merge(@metadata)
  end
end

class MSTask
  attr_reader :tasks

  def initialize(modules, build_engine)
    @tasks = tasks_in_modules(modules)

    @tasks.each do |cls|
      MSTask.class_eval do
        define_method cls.to_clr_type.name.to_sym do |args|
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

  def tasks_in_modules(modules)  
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
end

logger = Logger.new(STDOUT)
logger.level = Logger::INFO
$buildEngine = RubyBuildEngine.new(logger)

class AssemblyLoader
  @@assembly_paths = []
  
  def self.add_path(path)
    @@assembly_paths.push(path)
  end

  System::AppDomain.current_domain.assembly_resolve do |sender, event| 
    found_path = nil
    @@assembly_paths.each do |path|
      assembly_path = System::IO::Path.get_full_path(path+event.name)
      if System::IO::File.exists(assembly_path)
        found_path = assembly_path
      end
    end
    throw System::IO::FileNotFoundException.new(event.name) if not found_path
    System::Reflection::Assembly.LoadFile(found_path)
  end
end

def tasks_for_module(mod)
  MSTask.new([mod], $buildEngine)
end
