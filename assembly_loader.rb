require 'set'

class AssemblyLoader
  @@assembly_paths = Set.new

  def self.add_path(path)
    raise Exception.new "Path cannot be nil" if path == nil
    @@assembly_paths.add(path) if path != nil
  end

  System::AppDomain.current_domain.assembly_resolve do |sender, event|
    found_path = nil
    @@assembly_paths.each do |path|
      assembly_path = System::IO::Path.get_full_path(System::IO::Path.combine(path,event.name))
      if System::IO::File.exists(assembly_path)
        found_path = assembly_path
        break
      end
    end
    throw System::IO::FileNotFoundException.new(event.name) unless found_path
    System::Reflection::Assembly.LoadFile(found_path)
  end
end
