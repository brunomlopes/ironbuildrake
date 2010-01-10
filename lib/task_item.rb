require 'Microsoft.Build.Tasks'

class TaskItem
  include Microsoft::Build::Framework::ITaskItem
  attr_accessor :item_spec, :metadata

  def initialize(strOrTaskItem)
    if strOrTaskItem.kind_of?(TaskItem)
      @item_spec = strOrTaskItem.item_spec
      @metadata = strOrTaskItem.metadata
    else
      @item_spec = strOrTaskItem
      @metadata = {}
    end
  end

  def metadata_count
    return @metadata.length
  end

  def metadata_names
    return @metadata.keys
  end

  def to_s
    return @item_spec
  end

  def get_metadata(metadata_name) # string => string
    if @metadata.has_key?(metadata_name)
      return @metadata[metadata_name]
    else
      return ""
    end
  end

  def merge_metadata!(metadata)
    @metadata.merge!(metadata)
    return self
  end

  def set_metadata(metadata_name, metadata_value) # string,string => void
    @metadata[metadata_name] = metadata_value
  end

  def remove_metadata(metadata_name) # string => void
    @metadata.delete(metadata_name) if @metadata.has_key?(metadata_name)
  end

  def copy_metadata_to(destination_item) #itaskitem => void
    @metadata.each_pair do |key, value|
      original_metadata = destination_item.get_metadata(key)
      if original_metadata == nil or original_metadata == ""
        destination_item.set_metadata(key, value)
      end
    end
    original_item_spec = destination_item.get_metadata("OriginalItemSpec")
    if original_item_spec == nil or original_item_spec == ""
      destination_item.set_metadata("OriginalItemSpec", @item_spec)
    end
  end

  def clone_custom_metadata()# void => IDictionary
    return Hash.new().merge(@metadata)
  end
end
