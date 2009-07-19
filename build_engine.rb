require 'Microsoft.Build.Tasks'

include Microsoft

class RubyBuildEngine 
  include Microsoft::Build::Framework::IBuildEngine

  def BuildProjectFile(projectFileName, # string
                       targetNames, # string[] 
                       globalProperties, # IDictionary
                       targetOutputs #IDictionary
                       )
    return true
  end

  def log_event(e)
    puts("#{e.Timestamp}:#{e.ThreadId}:#{e.SenderName}:#{e.Message}")
  end
  
  def log_custom_event(e) # CustomBuildEventArgs
    log_event(e)
    puts("\tCustom")
  end
  def log_error_event(e) #BuildErrorEventArgs
    log_event(e)
    puts("\tError:#{e.Code}:#{e.ColumnNumber}:#{e.EndColumnNumber}:#{e.EndLineNumber}:#{e.File}:#{e.LineNumber}:#{e.Subcategory}")
  end
  def log_message_event(e) #BuildMessageEventArgs
    log_event(e)
    puts("\tMessage:#{e.Importance}:#{e.Message}")
  end
  def log_warning_event(e) #BuildWarningEventArgs
    log_event(e)
    puts("\tWarning: #{e.Code}:#{e.ColumnNumber}:#{e.EndColumnNumber}:#{e.EndLineNumber}:#{e.File}:#{e.LineNumber}:#{e.Subcategory}")
  end
  
  def column_number_of_task_node() #int
    return 1
  end
  def continue_on_error() #bool
    return true
  end
  def line_number_of_task_node() #int
    return 2
  end
  def project_file_of_task_node() #string
    return "project file"
  end
end

class ItemTask
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
    itask = Microsoft::Build::Framework::ITask.to_clr_type
    itaskitem = Microsoft::Build::Framework::ITaskItem
    @tasks = []
    modules.each do |mod|
      classes = mod.constants.map { |c| mod.class_eval(c) }
      classes = classes.select do |cls|
        if !cls.respond_to?(:to_clr_type) || !cls.to_clr_type.respond_to?(:get_interfaces)
          interfaces = []
        else
          interfaces = cls.to_clr_type.get_interfaces()
          end
        interfaces.include?(itask)
      end
      @tasks.concat(classes)
    end

    @tasks.each do |cls| 
      MSTask.class_eval do 
        define_method cls.to_clr_type.name.to_sym do |args|
          args ||= {}
          instance = cls.new
          instance.BuildEngine = build_engine

          properties = instance.class.to_clr_type.get_properties

          args.each_pair do |k,v|
            property = properties.find {|prop| prop.name.downcase == k.to_s.downcase}
            if property == nil
              return
            end

            value = v
            if value.kind_of?(Array)
              value = System::Array.of(itaskitem).new(v.map{|item| ItemTask.new(item)})
            elsif value.kind_of?(String)
              value = value.to_clr_string
            end
            begin
              property.set_value(instance, value, nil)
            rescue ArgumentError
              value = System::Array.of(itaskitem).new([value].map{|item| ItemTask.new(item)})
              property.set_value(instance, value, nil)
            end
          end 
          instance.Execute
        end
      end
    end
  end
end

$buildEngine = RubyBuildEngine.new

def msBuild()
  modules = [Microsoft::Build::Tasks]
  MSTask.new(modules, $buildEngine)
end
