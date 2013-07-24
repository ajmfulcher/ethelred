class BBCRestClient
  def get url
    retriable_get url
  end
  
  private
  
  def retriable_get url
    retriable :on => Timeout::Error, :tries => 5, :interval => 1 do
      RestClient::Resource.new(url).get(:accept => "application/json-ld")
    end
  end
end