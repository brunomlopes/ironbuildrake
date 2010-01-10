require "test/unit"
require "tasks_file"
require 'helper'

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

  def test_add_file_to_already_existing_group
    original = <<XML
    <Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
      <PropertyGroup>
        <variable>value</variable>
      </PropertyGroup>
    </Project>
XML
    second = <<XML
    <Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
      <PropertyGroup>
        <propertyName>property $(variable)</propertyName>
      </PropertyGroup>
    </Project>
XML

    properties = PropertyGroups.from_xml(original).add_xml(second)

    assert_equal "property value", properties.propertyName
  end

  def test_file_added_later_can_resolve_variables_in_first
    original = <<XML
    <Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
      <PropertyGroup>
        <propertyName>property $(variable)</propertyName>
      </PropertyGroup>
    </Project>
XML

    second = <<XML
    <Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
      <PropertyGroup>
        <variable>value</variable>
      </PropertyGroup>
    </Project>
XML

    properties = PropertyGroups.from_xml(original)

    assert_equal "property ", properties.propertyName

    properties = properties.add_xml(second)
    assert_equal "property value", properties.propertyName
  end

  "regression"
  def test_properties_from_sdc
    text = <<XML
<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <BuildPath Condition="'$(BuildPath)'==''">$(MSBuildProjectDirectory)\\</BuildPath>
    <TasksPath Condition="Exists('$(BuildPath)\\bin\\Microsoft.Sdc.Tasks.dll')">$(BuildPath)\\bin\\</TasksPath>
  </PropertyGroup>
</Project>
XML

    properties = PropertyGroups.from_xml(text)
    assert_equal("\\", properties.BuildPath)
    assert_equal("\\\\bin\\", properties.TasksPath)
  end
end
