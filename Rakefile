$: << "lib"

require 'rubygems'
require "build_engine.rb"
require 'rake/testtask'



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

task :test_scenario_1 do
  msbuild = tasks_from_module(Microsoft::Build::Tasks)
  # this should make the task fail the rake build if has error.

  msbuild.Warning({ :text => "This is a text message" }).fail_on_error

  # or perhaps the best way would be for it to be reversed
  msbuild.Warning({ :text => "This is a text message" }).proceed_on_error

end

desc "Run unit tests"
Rake::TestTask.new("test_units") do |t|
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
                :OutputAssembly => "tool\\ibrake.exe" })

  msbuild.Copy({ :SourceFiles => ["tool\\ibrake.exe", "tool\\ibrake.exe.config"], :DestinationFolder => ironruby_path })
end
