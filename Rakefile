$: << "lib"

require 'rubygems'
require "build_engine.rb"
require 'rake/testtask'

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

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "ironbuildrake #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "this is just a quick smoke test"
task :test do
  msbuild = tasks_from_module(Microsoft::Build::Tasks)
  msbuild.Message :text => "This is a text message"
  msbuild.Warning :text => "This is a warning"
end

desc "Run unit tests"
Rake::TestTask.new("run_tests") do |t|
  t.libs << "test"
  t.pattern = 'test/tests_*.rb'
  t.verbose = true
  t.warning = true
end

desc "build ibrake.exe wrapper"
task :build_ibrake do
  ironruby_path = System::IO::FileInfo.new(System::Reflection::Assembly.get_executing_assembly.location).directory_name
  msbuild = tasks_from_module(Microsoft::Build::Tasks)
  msbuild.Csc({ :AdditionalLibPaths => ironruby_path,
                :References => ["IronRuby.dll", "Microsoft.Scripting.dll", "Microsoft.Scripting.Core.dll", "Microsoft.Dynamic.dll"],
                :Sources => ["tool\\ibrake.cs"],
                :OutputAssembly => "tool\\ibrake.exe",
                :Platform => "x86"})

  msbuild.Copy({ :SourceFiles => ["tool\\ibrake.exe", "tool\\ibrake.exe.config"], :DestinationFolder => ironruby_path })
end
