require 'Microsoft.Build.Tasks'
require 'logger'
require 'tasks_file'
require 'task_library'

class RubyBuildEngine
  include Microsoft::Build::Framework::IBuildEngine
  # include Microsoft::Build::Framework::IBuildEngine2
  attr_reader :column_number_of_task_node, :continue_on_error, :line_number_of_task_node,
               :project_file_of_task_node, :is_running_multiple_nodes

  def initialize(logger)
    @logger = logger
    @column_number_of_task_node = 1
    @continue_on_error = true
    @line_number_of_task_node = 2
    @project_file_of_task_node = "project.file"
    @is_running_multiple_nodes = false
  end



  def build_project_file(project_file_name, # string
  target_names, # string[]
  global_properties, # IDictionary
  target_outputs, #IDictionary
  tools_version #string
  )
    return true
  end

  def BuildProjectFilesInParallel(project_file_names, #string[]
  target_names, #string[],
  global_properties, #IDictionary[]
  target_outputs_per_project, #IDictionary[]
  tools_version, #string[]
  use_results_cache, #bool
  unload_projects_on_completion) #bool
    return true
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

end

logger = Logger.new(STDOUT)
logger.level = Logger::INFO
$build_engine = RubyBuildEngine.new(logger)



def tasks_from_module(mod)
  TaskLibrary.from_modules($build_engine, mod)
end

def tasks_from_file(tasks_file)
  TaskLibrary.from_tasks_file($build_engine, tasks_file)
end

def properties_from_file(properties_file)
  PropertyGroups.from_file(properties_file)
end


def tasks_from_msbuild_2_0()
  load_assembly 'Microsoft.Build.Tasks, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a'
  #directory = System::Runtime::InteropServices::RuntimeEnvironment.get_runtime_directory
  #file_name = "Microsoft.Common.Tasks"
  #full_path = System::IO::Path.combine(directory, file_name)
  return TaskLibrary.from_modules($build_engine, Microsoft::Build::Tasks)
end

def tasks_from_msbuild_3_5()
   directory = System::Environment.expand_environment_variables('%WINDIR%\Microsoft.NET\Framework\v3.5')
   file_name = "Microsoft.Common.Tasks"
   full_path = System::IO::Path.combine(directory, file_name)
   return TaskLibrary.from_tasks_file($build_engine, full_path)
end
