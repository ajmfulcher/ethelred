require 'json'
require 'retriable'
require 'uri'
require 'cgi'
require_relative 'bbc_rest_client'

class DBPediaRestClient

  def initialize rest_client = BBCRestClient.new, base_url = "http://dbpedia.org/sparql?default-graph-uri=http://dbpedia.org&format=application/json&timeout=30000&query="
    @rest_client = rest_client
    @base_url = base_url
    @labels = {}
  end

  def get_label(uri)
    if @labels[uri].nil?
      @labels[uri] = request_label(uri)
    end
    @labels[uri]
  end

  def get_person dbpedia_id
    sparql = build_person_sparql(dbpedia_id)
    json = safe_get_json sparql
    if json['results']['bindings'][0]
      person = json['results']['bindings'][0]
      person['relations'] = get_related_people(dbpedia_id, 5)
      person = simplify_json(person)
      person['description'] = person['description'].split('.').first + '.'
      @labels[dbpedia_id] = person['name']
      person
    else
      nil
    end
  end

  def get_related_people dbpedia_id, count=20
    sparql = build_related_people_sparql(dbpedia_id, count)
    json = safe_get_json sparql
    if json['results']['bindings']
      people = json['results']['bindings']
      simplify_json(people)
    else
      nil
    end
  end

  def get_relations(dbpedia_id, dbpedia_id2)
    puts dbpedia_id + ", " + dbpedia_id2
    sparql = build_relations_sparql(dbpedia_id, dbpedia_id2)
    json = safe_get_json sparql
    if json['results']['bindings']
      relations = json['results']['bindings']
      simplify_json(relations)
    else
      nil
    end
  end

  def get_people_with_property(property, value)
    sparql = build_people_with_property_sparql(property, value)
    json = safe_get_json sparql
    if json['results']['bindings']
      people = json['results']['bindings']
      simplify_json(people)
    else
      nil
    end
  end

  def get_fact(ids)
    ids.each_with_index do |first, index|
      ids[index+1..-1].each do |second|
        relations = get_relations(first, second)
        if !relations.empty?
          return generate_fact(first, second, relations)
        end
      end
    end
    "There is nothing relating any of these people! Wow, so much for Kevin Bacon."
  end

  private

  def request_label dbpedia_id
    sparql = build_label_sparql(dbpedia_id)
    json = safe_get_json sparql
    if json['results']['bindings'][0]
      person = json['results']['bindings'][0]
      person = simplify_json(person)
      person['name']
    else
      nil
    end
  end

  def generate_fact(first, second, relations)
    relation = relations.sample
    firstPerson = get_label(first)
    secondPerson = get_label(second)
    "#{firstPerson} and #{secondPerson} both had #{relation['value']} as their #{relation['relationship']}."
  end

  def build_label_sparql dbpedia_id
    "select ?name where {
    <#{dbpedia_id}> <http://www.w3.org/2000/01/rdf-schema#label> ?name .
    FILTER (lang(?name)=\"en\") .
    }"
  end

  def build_person_sparql dbpedia_id
    "select ?name ?birthdate ?description ?thumb where {
    <#{dbpedia_id}> <http://www.w3.org/2000/01/rdf-schema#label> ?name ;
    <http://dbpedia.org/property/birthDate> ?birthdate ;
    <http://www.w3.org/2000/01/rdf-schema#comment> ?description
    FILTER (lang(?description)=\"en\")
    FILTER (lang(?name)=\"en\") .
    OPTIONAL { <#{dbpedia_id}> <http://dbpedia.org/ontology/thumbnail> ?thumb .}} LIMIT 1"
  end


  def build_people_with_property_sparql property, value
      "select ?name ?thumb where {
    ?person <#{property}> <#{value}> ;
    <http://www.w3.org/2000/01/rdf-schema#label> ?name ;
    FILTER (lang(?name)=\"en\") .
    OPTIONAL { ?person <http://dbpedia.org/ontology/thumbnail> ?thumb .}} LIMIT 1"
  end

  def build_related_people_sparql dbpedia_id, count
    "PREFIX dcterms: <http://purl.org/dc/terms/>
     PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

     SELECT DISTINCT ?name ?subject ?thumb ?person_ref ?subject_ref WHERE {
            <#{dbpedia_id}> dcterms:subject ?subject_ref .
            ?person_ref a <http://dbpedia.org/ontology/Person> .
            ?person_ref <http://www.w3.org/2000/01/rdf-schema#label> ?name ;
            dcterms:subject ?subject_ref .
            ?subject_ref <http://www.w3.org/2000/01/rdf-schema#label> ?subject .
            FILTER ( ?subject_ref != <http://dbpedia.org/resource/Category:Living_people> )
            FILTER (lang(?name)=\"en\")
            FILTER (lang(?subject)=\"en\")
            OPTIONAL { ?person_ref <http://dbpedia.org/ontology/thumbnail> ?thumb .}
     }
     ORDER BY RAND()
     LIMIT #{count}"
  end

  def build_relations_sparql dbpedia_id, dbpedia_id2
    "PREFIX dcterms: <http://purl.org/dc/terms/>
     PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
     SELECT DISTINCT ?relationship ?value WHERE {
         <#{dbpedia_id}> ?r ?v .
         <#{dbpedia_id2}> ?r ?v .
         FILTER (?r != <http://www.w3.org/1999/02/22-rdf-syntax-ns#type>
&& ?r != <http://dbpedia.org/property/wikiPageUsesTemplate>
&& ?r != <http://dbpedia.org/property/wordnet_type> )
         ?r <http://www.w3.org/2000/01/rdf-schema#label> ?relationship .
         ?v <http://www.w3.org/2000/01/rdf-schema#label> ?value .
            FILTER (lang(?relationship)=\"en\")
            FILTER (lang(?value)=\"en\")
}"
  end

  def simplify_json object
    if object.kind_of?(Array)
      simple = []
      object.each do | item |
        simple << simplify_json(item)
      end
    elsif object.kind_of?(Hash)
      if object.has_key?('type')
        simple = object['value']
      else
        simple = {}
        object.map do | key, typedThing |
          simple[key] = simplify_json(typedThing)
        end
      end
    else
      simple = object
    end

    simple
  end

  def safe_get_json path
    url = "#{@base_url}#{CGI.escape(path)}"
    p url
    response = @rest_client.get(url,{:accept => "application/json"})

    if response.code != 200
      raise CoreClientError.new "HTTP response for #{url} was #{response.code}"
    end

    JSON.parse(response.body)
  end

end