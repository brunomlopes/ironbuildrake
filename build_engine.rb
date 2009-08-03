require 'Microsoft.Build.Tasks'
require 'logger'
require 'targets_file'
require 'task_library'

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

logger = Logger.new(STDOUT)
logger.level = Logger::INFO
$buildEngine = RubyBuildEngine.new(logger)



def tasks_for_module(mod)
  TaskLibrary.from_modules($buildEngine, mod)
end
