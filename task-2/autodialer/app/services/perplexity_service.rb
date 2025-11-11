require 'net/http'

class PerplexityService
  API_URI = URI("https://api.perplexity.ai/chat/completions")

  def self.http_client
    Thread.current[:pplx_http] ||= begin
      http = Net::HTTP.new(API_URI.host, API_URI.port)
      http.use_ssl = true
      http
    end
  end

  def gen_blog(title:)
    request = Net::HTTP::Post.new(API_URI.path, { 'Content-Type' => 'application/json' })
    request['Authorization'] = "Bearer #{ENV["PPLX_TOKEN"]}"
    request.body = {
      max_tokens: 1024,
      model: "sonar",
      messages: [
        {
          role: "user", 
          content: "Write a blog on #{title}"
        }
      ]
    }.to_json

    response = self.class.http_client.request(request)

    case response
    when Net::HTTPSuccess, Net::HTTPRedirection
      resp = JSON.parse(response.body)
      resp["choices"][0]["message"]["content"]
    else
      raise "API Error: #{response.code} - #{response.message}"
    end

  end
end
