require "test/unit"
require "tasks_file"

class TestTargetsFile < Test::Unit::TestCase
  def test_tasks
    text = <<XML
    <Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
      <UsingTask AssemblyFile="Tasks.dll" TaskName="UpdateDependencies"  />
    </Project>
XML

    targets = TasksFile.from_xml(text)
    assert_equal(1, targets.task_infos.size)
    task = targets.task_infos[0]
    assert_equal("Tasks.dll", task.assembly_file)
    assert_equal("UpdateDependencies", task.task_name)
  end

  def test_assemblies_are_the_same
    text = <<XML
    <Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
      <UsingTask AssemblyFile="Tasks.dll" TaskName="UpdateDependencies"  />
      <UsingTask AssemblyFile="Tasks.dll" TaskName="OtherTask"  />
    </Project>
XML

    targets = TasksFile.from_xml(text)
    assert_equal(1, targets.assembly_file_names.size)
    assert(targets.assembly_file_names.include?("Tasks.dll"))
  end

  def test_assemblies_are_diferent
    text = <<XML
    <Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
      <UsingTask AssemblyFile="Tasks.dll" TaskName="UpdateDependencies"  />
      <UsingTask AssemblyFile="OtherAssembly.dll" TaskName="OtherTask"  />
    </Project>
XML

    targets = TasksFile.from_xml(text)
    assert_equal(2, targets.assembly_file_names.size)
    assert(targets.assembly_file_names.include?("Tasks.dll"))
    assert(targets.assembly_file_names.include?("OtherAssembly.dll"))
  end

  def test_tasks_from_msbuild_have_correct_assembly_name
    directory = System::Runtime::InteropServices::RuntimeEnvironment.get_runtime_directory
    file_name = "Microsoft.Common.Tasks"
    full_path = System::IO::Path.combine(directory, file_name)
    targets = TasksFile.from_file(full_path)

    assert_equal(41, targets.task_infos.size)
    assert_equal(1, targets.assembly_names.size)
    tasks_assembly_name = "Microsoft.Build.Tasks, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"
    assert(targets.assembly_names.include?(tasks_assembly_name),
           " #{targets.assembly_names.to_a} does not include #{tasks_assembly_name}")
  end

  
  def test_tasks_can_load_msbuild_v3_5_tasks_assembly
    directory = System::Environment.expand_environment_variables('%WINDIR%\Microsoft.NET\Framework\v3.5')
    file_name = "Microsoft.Common.Tasks"
    full_path = System::IO::Path.combine(directory, file_name)
    targets = TasksFile.from_file(full_path)

    targets.load_assemblies()
    assert_instance_of(Class, Microsoft::Build::Tasks::AssignProjectConfiguration)
  end

  def test_tasks_with_properties
    text = <<XML
    <Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
      <PropertyGroup>
        <property>value</property>
      </PropertyGroup>
      <UsingTask AssemblyFile="$(property).Tasks.dll" TaskName="UpdateDependencies"  />
    </Project>
XML

    targets = TasksFile.from_xml(text)
    assert_equal(1, targets.task_infos.size)
    task = targets.task_infos[0]
    assert_equal("value.Tasks.dll", task.assembly_file)
    assert_equal("UpdateDependencies", task.task_name)
  end
end

class TestPropertyGroupParser < Test::Unit::TestCase
  def test_simple_property
    text = <<XML
    <Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
      <PropertyGroup>
        <propertyName>property value</propertyName>
      </PropertyGroup>
    </Project>
XML

    properties = PropertyGroups.from_xml(text)
    assert_equal("property value", properties.propertyName)
  end

  def test_property_defined_in_terms_of_another
    text = <<XML
    <Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
      <PropertyGroup>
        <variable>value</variable>
        <propertyName>property $(variable)</propertyName>
      </PropertyGroup>
    </Project>
XML

    properties = PropertyGroups.from_xml(text)
    assert_equal("property value", properties.propertyName)
  end

  def test_property_defined_in_terms_of_another_two
    text = <<XML
    <Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
      <PropertyGroup>
        <first>value</first>
        <second>$(first)</second>
        <propertyName>property $(second)</propertyName>
      </PropertyGroup>
    </Project>
XML

    properties = PropertyGroups.from_xml(text)
    assert_equal("property value", properties.propertyName)
  end

  def test_property_defined_in_terms_of_another_two_jumbled
    text = <<XML
    <Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
      <PropertyGroup>
        <second>$(first)</second>
        <propertyName>property $(second)</propertyName>
        <first>value</first>
      </PropertyGroup>
    </Project>
XML

    properties = PropertyGroups.from_xml(text)
    assert_equal("property value", properties.propertyName)
  end

  def test_properties_can_be_loaded
    text = <<XML
    <Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
      <PropertyGroup>
        <weListenTasksPath Condition="'$(weListenTasksPath)' == ''">.</weListenTasksPath>
        <weListenDependenciesTasksLib>$(weListenTasksPath)\\weListen.Dependencies.Tasks.dll</weListenDependenciesTasksLib>
      </PropertyGroup>
    </Project>
XML

    PropertyGroups.from_xml(text)
  end
end