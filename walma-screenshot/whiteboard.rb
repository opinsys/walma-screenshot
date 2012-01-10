
require 'net/http'
require 'net/https'
require "base64"
require "json"
require 'uri'

class WhiteboardError < StandardError; end

class Whiteboard

  def initialize(domain)
    if domain[-1].chr == "/"
      domain = domain[0...-1]
    end

    @domain = domain

    @url = URI.parse @domain + "/api/create"
  end

  def post(data)
    base = Base64.encode64 data
    req = Net::HTTP::Post.new(@url.path)
    req.set_form_data( 'image' => base )
    http = Net::HTTP.new(@url.host, @url.port)

    if @url.port == 443
      http.use_ssl = true
    end

    $stderr.puts "posting screenshot to #{ @url }"
    res = http.start {|http| http.request(req) }
    case res
    when Net::HTTPSuccess
      res_json = JSON.parse res.body
      $stderr.puts "Walma gave path #{ res_json['url'] }"
      "#{ @domain }#{ res_json['url'] }"
    else
      raise WhiteboardError, _("Something failed while posting to whiteboard")
    end
  end
end
