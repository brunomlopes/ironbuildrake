require "test/unit"
require "targets_file"

class TestTargetsFile < Test::Unit::TestCase
  # Fake test
  def test_tasks
    text = <<META
    <Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
      <UsingTask AssemblyFile="weListen.Dependencies.Tasks.dll" TaskName="weListen.Dependencies.Tasks.UpdateDependencies"  />
    </Project>
META

    TargetsFile.from_xml(text)
  end
end

class TestPropertyGroupParser < Test::Unit::TestCase
  def test_simple_property
    text = <<META
    <Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
      <PropertyGroup>
        <propertyName>property value</propertyName>
      </PropertyGroup>
    </Project>
META

    properties = PropertyGroups.from_xml(text)
    assert_equal("property value", properties.propertyName)
  end

  def test_property_defined_in_terms_of_another
    text = <<META
    <Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
      <PropertyGroup>
        <variable>value</variable>
        <propertyName>property $(variable)</propertyName>
      </PropertyGroup>
    </Project>
META

    properties = PropertyGroups.from_xml(text)
    assert_equal("property value", properties.propertyName)
  end

  def test_property_defined_in_terms_of_another_two
    text = <<META
    <Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
      <PropertyGroup>
        <first>value</first>
        <second>$(first)</second>
        <propertyName>property $(second)</propertyName>
      </PropertyGroup>
    </Project>
META

    properties = PropertyGroups.from_xml(text)
    assert_equal("property value", properties.propertyName)
  end

  def test_property_defined_in_terms_of_another_two_jumbled
    text = <<META
    <Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
      <PropertyGroup>
        <second>$(first)</second>
        <propertyName>property $(second)</propertyName>
        <first>value</first>
      </PropertyGroup>
    </Project>
META

    properties = PropertyGroups.from_xml(text)
    assert_equal("property value", properties.propertyName)
  end

  def test_properties_can_be_loaded
    text = <<META
    <Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
      <PropertyGroup>
        <weListenTasksPath Condition="'$(weListenTasksPath)' == ''">.</weListenTasksPath>
        <weListenDependenciesTasksLib>$(weListenTasksPath)\\weListen.Dependencies.Tasks.dll</weListenDependenciesTasksLib>
      </PropertyGroup>
    </Project>
META

    PropertyGroups.from_xml(text)
  end
end