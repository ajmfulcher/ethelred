require 'rubygems'
require 'sinatra'
require 'json'
require 'sinatra/partial'
require 'rest-client'

require_relative 'lib/core_client'

if ENV['PASSWORD']
  use Rack::Auth::Basic, "Restricted Area" do |username, password|
    username == 'admin' and password == ENV['PASSWORD']
  end
end

configure do
  set :client, CoreClient.new(ENV["MASHERY_KEY"])
  if ENV["SERVER_ENV"] == "sandbox"
    RestClient.proxy = "http://www-cache.reith.bbc.co.uk:80"
  end
end

get '/' do
  haml :index
end

get '/people/:document' do
  "people endpoint #{params[:document]}"
end

get '/person/:id' do
  "person endpoint #{params[:id]}"
end
