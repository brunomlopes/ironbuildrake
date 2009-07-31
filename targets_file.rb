require "rexml/document"
include REXML

class TargetsFile
  def self.from_xml(xml)
    document = Document.new(xml)
    puts "From xml"
    document.elements.each("Project/UsingTask") do |element|
      puts element.attributes["AssemblyFile"]
      puts element.attributes["TaskName"]
    end
    puts "End"
  end
end

class PropertyGroups
  def self.from_xml(xml)
    document = Document.new(xml)
    properties = Hash.new
    document.elements.each("Project/PropertyGroup/*") do |element|
      properties[element.name] = element.text.strip
    end
    return PropertyGroups.new(properties)
  end

  def initialize(elements)
    variable_regexp = /\$\([\w]+\)/
    elements.each_pair do |key, value|
      PropertyGroups.class_eval do
        define_method key.to_sym do ||
          replaced_value = value
          while variable_regexp.match(replaced_value)
            match = variable_regexp.match(replaced_value)
            full_var = match[0]
            var_name = full_var[2..-2]
            if elements.key? var_name
              replaced_value = replaced_value.sub(full_var, elements[var_name])
            else
              replaced_value = replaced_value.sub(full_var, "")
            end
          end
          return replaced_value
        end
      end
    end
  end
end
