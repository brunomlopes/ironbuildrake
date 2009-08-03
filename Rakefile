require 'rubygems'
require "build_engine.rb"
require 'rake/testtask'


task :default => [:test_units]

desc "this is just a quick smoke test"
task :test => [:prerequesite] do
  msbuild = tasks_from_module(Microsoft::Build::Tasks)
  msbuild.Message :text => "This is a text message"
  msbuild.Warning :text => "This is a warning"
end

desc "Run basic tests"
Rake::TestTask.new("test_units") do |t|
  t.pattern = 'tests_*.rb'
  t.verbose = true
  t.warning = true
end