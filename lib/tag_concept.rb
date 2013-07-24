require_relative 'json_helper'

class TagConcept
  def initialize json
    @json = json
  end
  
  def uri
    @json['@id']
  end
  
  def type
    JSONHelper.normalize_array(@json['@type'])
  end
  
  def label
    JSONHelper.normalize_array(@json['label']).first
  end
  
  def preferred_label
    JSONHelper.normalize_array(@json['preferredLabel']).first
  end
  
  def name
    JSONHelper.normalize_array(@json['name']).first
  end
  
  def canonical_name
    JSONHelper.normalize_array(@json['canonicalName']).first
  end
  
  def guid
    regex = /([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}/
    matches = regex.match(uri)
    if matches
      matches[0]
    else
      nil
    end
  end
  
  def to_s
    # TODO Test this
    preferred_label || name || canonical_name || label || "No Label"
  end
end