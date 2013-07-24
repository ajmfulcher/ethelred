require 'date'

require_relative 'tag'
require_relative 'json_helper'

class CreativeWork
  def initialize json
    @json = json
  end
  
  def uri
    @json['@id']
  end
  
  def title
    @json['title']
  end
  
  def short_title
    @json['shortTitle']
  end
  
  def description
    @json['description']
  end
  
  def as_object
    about_tags = if about
      about.map { |tag| tag.as_object }
    end
    mentions_tags = if mentions
      mentions.map { |tag| tag.as_object }
    end
    {
      title: title,
      uri: uri,
      tags: about_tags,
      mentions: mentions_tags
    }
  end
  
  def url
    poten = JSONHelper.normalize_array(@json['primaryContentOf'])
    non_mobile_urls = poten.select { |u| u.include?("mobile") == false }
    if non_mobile_urls
      url = non_mobile_urls.first
      if url.class == Hash
        url["@id"]
      else
        url
      end
    else
      urls.first
    end
  end
  
  def locator
    JSONHelper.normalize_array(@json['locator'])
  end
  
  def created_date
    DateTime.parse(@json['dateCreated'])
  end
  
  def modified_date
    DateTime.parse(@json['dateModified'])
  end
  
  def friendly_modified_date
    modified_date.strftime("%H:%M, %e %B %Y")
  end
  
  def thumbnail
    if JSONHelper.normalize_array(@json['thumbnail'])
      thumbnails = JSONHelper.normalize_array(@json['thumbnail']).select do |thumb|
        if thumb.class == Hash
          thumb['thumbnailType'].include? "StandardThumbnail"
        end
      end
      if JSONHelper.normalize_array(thumbnails).first
        if JSONHelper.normalize_array(thumbnails).first['@id']
          JSONHelper.normalize_array(thumbnails).first['@id'].gsub("#image", "")
        end
      end
    end
  end
  
  def about
    tag('about')
  end
  
  def mentions
    tag('mentions')
  end
  
  private
  
  def tag type
    if @json[type]
      tags = JSONHelper.normalize_array(@json[type])
      new_tags = tags.map do |tag|
        if tag['@id']
          Tag.new tag
        end
      end
      new_tags.select { |t| nil != t }
    else
      nil
    end
  end
end