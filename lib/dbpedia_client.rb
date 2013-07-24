require 'json'
require 'retriable'
require 'uri'
require_relative 'core_client'

class DBPediaRestClient

  def initialize rest_client = BBCRestClient.new, base_url = "http://dbpedia.org/sparql?default-graph-uri=http://dbpedia.org&format=application/json&timeout=30000&query="
    @rest_client = rest_client
    @base_url = base_url
  end

  def get_person id
    dbpedia_id = id
    sparql = build_person_sparql(dbpedia_id)
    json = safe_get_json sparql
    if json['results']['bindings']
      json['results']['bindings'][0]
    else
      nil
    end
  end

  private

  def build_person_sparql dbpedia_id
    "select ?name ?comment ?thumb where {<http://dbpedia.org/resource/#{dbpedia_id}>
    <http://dbpedia.org/property/name> ?name ;
    <http://www.w3.org/2000/01/rdf-schema#comment> ?comment
    FILTER (lang(?comment)=\"en\")
    FILTER (lang(?name)=\"en\") .
    OPTIONAL { <#{dbpedia_id}> <http://dbpedia.org/ontology/thumbnail> ?thumb .}} LIMIT 1"
  end

  def safe_get_json path
    url = URI.escape("#{@base_url}#{path}")
    puts url
    response = @rest_client.get url

    if response.code != 200
      raise CoreClientError.new "HTTP response for #{url} was #{response.code}"
    end

    JSON.parse(response.body)
  end

end