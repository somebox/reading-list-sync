module Bookmark
  USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:34.0) Gecko/20100101 Firefox/34.0"

  def still_online?
    response = Typhoeus.get(self.url, followlocation: true, headers: {"User-Agent"=>USER_AGENT})
    response.success?
  end
end
