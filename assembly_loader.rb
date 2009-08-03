require 'set'

class AssemblyLoader
  @@assembly_paths = Set.new

  def self.add_path(path)
    @@assembly_paths.add(path)
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