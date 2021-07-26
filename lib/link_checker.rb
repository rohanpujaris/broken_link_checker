require 'net/http'

class LinkChecker
  TEMPORARY_REDIRECT_CODES = %w[302 303 307]

  def self.run(url, max_limit = 2)
    uri = url.is_a?(URI) ? url : URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == "https"
    http.read_timeout = 10

    begin
      response = http.request(Net::HTTP::Get.new(uri))
      if TEMPORARY_REDIRECT_CODES.include?(response.code)
        return Response::Know.new(response) if max_limit == 0
        location = response['location']
        new_location = URI.parse(location).relative? ? URI.join(uri, location) : location
        run(new_location, max_limit - 1)
      else
        Response::Know.new(response)
      end
    rescue StandardError => e
      Response::Unkow.new(e)
    end
  end
end
