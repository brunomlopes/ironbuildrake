# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ironbuildrake}
  s.version = "0.1.1"
  s.platform = %q{ironruby}

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bruno Lopes"]
  s.date = %q{2009-12-26}
  s.description = %q{}
  s.email = %q{brunomlopes@gmail.com}
  s.extra_rdoc_files = [
    "README"
  ]
  s.files = [
    "README",
     "Rakefile",
     "VERSION",
     "ironbuildrake.gemspec",
     "lib/Microsoft.Build.Tasks.rb",
     "lib/assembly_loader.rb",
     "lib/build_engine.rb",
     "lib/namespace_node.rb",
     "lib/task_item.rb",
     "lib/task_library.rb",
     "lib/tasks_file.rb"
  ]
  s.homepage = %q{http://github.com/brunomlopes/ironbuildrake}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Adds support for using msbuild tasks in ironruby with rake}
  s.test_files = [
    "test/helper.rb",
     "test/tests_namespace_node.rb",
     "test/tests_other_libraries.rb",
     "test/tests_targets_file.rb",
     "test/tests_tasks.rb",
     "test/tests_task_library.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

