require "build_engine.rb"

task :default => [:test]

task :prerequesite do
  puts "This is the pre-requesite"
end

task :test => [:prerequesite] do
  puts "This is my task"
  msBuild.Message :text => "This is text message"
end
