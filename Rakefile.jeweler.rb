begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "ironbuildrake"
    gem.summary = %Q{Adds support for using msbuild tasks in ironruby with rake }
    gem.description = %Q{}
    gem.email = "brunomlopes@gmail.com"
    gem.homepage = "http://github.com/brunomlopes/ironbuildrake"
    gem.authors = ["Bruno Lopes"]
    gem.files = FileList["[A-Z]*", "{lib, test}/**/*" ]
    gem.platform = "ironruby"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end
