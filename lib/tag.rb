require_relative 'json_helper'

class Tag
  attr_reader :uri
  
  def initialize json
    @json = json
  end
  
  def uri
    @json['@id']
  end
  
  def title
    preferred_label || label || short_label
  end
  
  def label
    attribute_safe("label").first
  end
  
  def preferred_label
    attribute_safe("preferredLabel").first
  end
  
  def same_as
    attribute_safe("sameAs")
  end
  
  def short_label
    attribute_safe("shortLabel").first
  end
  
  def name
    attribute_safe("name").first
  end
  
  def canonical_name
    attribute_safe("canonicalName").first
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
  
  def is_bbc_thing?
    uri.start_with? "http://www.bbc.co.uk/things/"
  end
  
  def to_s
    # TODO Test this
    label || preferred_label || name || canonical_name || "NaN"
  end
  
  def == other
    uri == other.uri
  end
  
  def as_object
    {
      uri: uri,
      title: title,
      name: name,
      preferred_label: preferred_label,
      guessed_name: guessed_name,
      dbpedia_uri: dbpedia_uri
    }
  end
  
  def dbpedia_uri
    wiki = same_as.select { |item| item.include? "dbpedia.org" }
    if wiki
      wiki.first
    end
  end
  
  def guessed_name
    wiki = same_as.select { |item| item.include? "dbpedia.org" }
    if wiki
      wiki.first.split("/").last.gsub("_", " ")
    end
  end
  
  private
  
  def attribute_safe name
    JSONHelper.normalize_array(@json[name])
  end
end