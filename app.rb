require 'rubygems'
require 'sinatra'
require 'json'
require 'sinatra/partial'
require 'rest-client'
require 'cgi'

require_relative 'lib/core_client'
require_relative 'lib/dbpedia_client'
require_relative 'lib/news_client'
require_relative 'lib/bbc_rest_client'

if ENV['PASSWORD']
  use Rack::Auth::Basic, "Restricted Area" do |username, password|
    username == 'admin' and password == ENV['PASSWORD']
  end
end

configure do
  set :dbpedia_client, DBPediaRestClient.new
  set :news_client, NewsClient.new
  set :client, BBCRestClient.new
  set :core_client, CoreClient.new(ENV["MASHERY_KEY"])
  if ENV["SERVER_ENV"] == "sandbox"
    RestClient.proxy = "http://www-cache.reith.bbc.co.uk:80"
  end
end

get '/' do
  haml :index
end

get '/news' do
  page = settings.news_client.get "/"
  page.html.to_s
end

get '/news/*' do
  page = settings.news_client.get params[:splat].first
  page.html.to_s
end

get '/api/tags' do
  query_params = {
    "webDocument" => CGI::escape(params[:url])
  }
  creative_work = settings.core_client.creative_works(query_params)
  creative_work.first.as_object.to_json
end

get '/person' do
  content_type :json
  dbpedia_id = params[:dbpedia]
  person = settings.dbpedia_client.get_person(dbpedia_id)
  JSON.pretty_generate(person) if !person.nil?
end

get '/people/related' do
  content_type :json
  dbpedia_id = params[:dbpedia]
  related = settings.dbpedia_client.get_related_people(dbpedia_id)
  JSON.pretty_generate(related) if !related.nil?
end

get '/people/relationship' do
  content_type :json
  dbpedia_id = params[:dbpedia]
  dbpedia_id2 = params[:dbpedia2]
  relations = settings.dbpedia_client.get_relations(dbpedia_id, dbpedia_id2)
  JSON.pretty_generate(relations) if !relations.nil?
end