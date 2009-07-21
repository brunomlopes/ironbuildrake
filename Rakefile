require "build_engine.rb"

msbuild = tasks_for_module(Microsoft::Build::Tasks)

task :default => [:test]

task :prerequesite do
  puts "This is the pre-requesite"
end

task :test => [:prerequesite] do
  puts "This is my task"
  msbuild.Message :text => "This is a text message"
  msbuild.Warning :text => "This is a warning"
end
