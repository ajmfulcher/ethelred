require 'json'
require 'retriable'

require_relative 'creative_work'
require_relative 'tag_concept'

class BBCRestClient
  def get url
    query_start = Time.now
    result = retriable_get url
    puts "Query for #{url} \n-- Took: #{Time.now - query_start}"
    result
  end
  
  private
  
  def retriable_get url
    # TODO Eventually, don't retry
    retriable :on => Timeout::Error, :tries => 5, :interval => 1 do
      RestClient::Resource.new(url).get(:accept => "application/json-ld")
    end
  end
end

class CoreClient
  def initialize api_key, rest_client = BBCRestClient.new, base_url = "http://ethelred-the-unready.ldpconnectedstudio.org.uk/ldp-core"
    @api_key = api_key
    @rest_client = rest_client
    @base_url = base_url
  end
  
  def creative_works params = { legacy: true }
    q_str = query_string params
    get_creative_works "creative-works?#{q_str}&api_key=#{@api_key}"
  end
  
  def tag_concepts params = { legacy: false }
    q_str = query_string params
    get_tag_concepts "tag-concepts?#{q_str.gsub(" ", "%20")}&api_key=#{@api_key}"
  end
  
  def things params = {}
    q_str = query_string params
    safe_get_json "dev/explore?#{q_str}&api_key=#{@api_key}"
  end
  
  private
  
  # TODO Repetition here - address this.
  
  def get_creative_works path
    json = safe_get_json path
    if json['results']
      json['results'].map do |result|
        CreativeWork.new result
      end
    else
      nil
    end
  end
  
  def get_tag_concepts path
    json = safe_get_json path
    if json['results']
      json['results'].map do |result|
        TagConcept.new result
      end
    else
      nil
    end
  end

  def query_string params
    param_array = params.map { |k, v| "#{k}=#{v}" }
    param_string = param_array.join("&")
  end
  
  def safe_get_json path
    url = "#{@base_url}/#{path}"
    puts url
    response = @rest_client.get url
    
    if response.code != 200
      raise CoreClientError.new "HTTP response for #{url} was #{response.code}"
    end
    
    JSON.parse(response.body)
  end
end

class CoreClientError < RuntimeError; end