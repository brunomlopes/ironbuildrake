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

class MSTask
  attr_reader :tasks

  def initialize(modules, buildEngine)
    itask = Microsoft::Build::Framework::ITask.to_clr_type
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
          instance.BuildEngine = buildEngine
          
          args.each_pair do |k,v|
            setter = "#{k}="
            instance.send(setter,v) if instance.respond_to?(setter)
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
