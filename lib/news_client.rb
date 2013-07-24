require 'nokogiri'

require_relative 'bbc_rest_client'

class NewsClient
  def initialize rest_client = BBCRestClient.new
    @rest_client = rest_client
  end
  
  def get slug
    response = @rest_client.get("http://www.bbc.co.uk/news/#{slug}")
    NewsPage.new response.body
  end
end

class NewsPage
  attr_accessor :html
  
  def initialize body
    @html = Nokogiri::HTML(body)
    inject_css "/css/inject.css"
    inject_js "/js/jquery.js"
    inject_js "/js/inject.js"
  end
  
  private
  
  def inject_css path
    body = @html.at_css "head"
    css_link = Nokogiri::XML::Node.new "link", @html
    css_link["rel"] = "stylesheet"
    css_link["type"] = "text/css"
    css_link["href"] = path
    body.add_child css_link
  end
  
  def inject_js path
    body = @html.at_css "head"
    css_link = Nokogiri::XML::Node.new "script", @html
    css_link["type"] = "text/javascript"
    css_link["src"] = path
    body.add_child css_link
  end
end