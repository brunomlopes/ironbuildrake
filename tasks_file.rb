require "rexml/document"
require "assembly_loader"
require "set"

include REXML

class TasksFile
  attr_reader :task_infos, :assembly_file_names, :assembly_names, :task_class_names

  def self.from_xml(xml, file_path = nil)
    document = Document.new(xml)
    properties = PropertyGroups.from_xml(xml)

    tasks = document.elements.to_a("Project/UsingTask").map do |element|
      assembly_file = properties.replace_variables_in(element.attributes["AssemblyFile"])
      assembly_name = properties.replace_variables_in(element.attributes["AssemblyName"])
      task_name = properties.replace_variables_in(element.attributes["TaskName"])
      TaskInfo.new(task_name, assembly_file, assembly_name)
    end

    return TasksFile.new(tasks, file_path)
  end

  def self.from_file(file_path)
    return self.from_xml(File.read(file_path), file_path)
  end

  def initialize(tasks, file_path = nil)
    @task_infos = tasks
    @assembly_file_names = Set.new(@task_infos.map {|task| task.assembly_file }).delete(nil)
    @assembly_names = Set.new(@task_infos.map {|task| task.assembly_name }).delete(nil)
    @task_class_names = Set.new(@task_infos.map {|task| task.task_name}).delete(nil)
    @file_path = file_path
  end

  def load_assemblies()
    AssemblyLoader.add_path(System::IO::Path.get_directory_name(@file_path)) if @file_path != nil

    @assembly_file_names.each do |assembly_file_name|
      task_file_directory = System::IO::Path.get_directory_name(assembly_file_name)
      AssemblyLoader.add_path(task_file_directory)

      assembly_file = System::IO::Path.get_file_name(assembly_file_name)
      load_assembly(assembly_file)
    end

    @assembly_names.each do |assembly_name|
      load_assembly(assembly_name)
    end
  end
end

class TaskInfo
  attr_reader :task_name, :assembly_file, :assembly_name

  def initialize(task_name, assembly_file, assembly_name)
    @task_name = task_name
    while assembly_file =~ /\\\\/
      assembly_file.gsub!(/\\\\/,"\\")
    end
    @assembly_file = assembly_file
    @assembly_name = assembly_name
  end
end

class PropertyGroups
  attr_reader :elements

  def self.from_xml(xml)
    document = Document.new(xml)
    properties = Hash.new
    document.elements.each("Project/PropertyGroup/*") do |element|
      properties[element.name] = element.text.strip
    end
    return PropertyGroups.new(properties)
  end

  def initialize(elements)
    @variable_regexp = /\$\([\w]+\)/
    @elements = elements
    elements.each_pair do |key, value|
      PropertyGroups.class_eval do
        define_method key.to_sym do ||
          return replace_variables_in(value)
        end
      end
    end
  end

  def replace_variables_in(str)
    replaced_value = str
    while @variable_regexp.match(replaced_value)
      match = @variable_regexp.match(replaced_value)
      full_var = match[0]
      var_name = full_var[2..-2]
      if elements.key? var_name
        replaced_value = replaced_value.sub(full_var, @elements[var_name])
      else
        replaced_value = replaced_value.sub(full_var, "")
      end
    end
    return replaced_value
  end
end
