class BBCRestClient
  def get (url, headers = {:accept => "application/json-ld"})
    retriable_get(url, headers)
  end
  
  private
  
  def retriable_get (url, headers = {})
    retriable :on => Timeout::Error, :tries => 5, :interval => 1 do
      RestClient::Resource.new(url).get(headers)
    end
  end
end