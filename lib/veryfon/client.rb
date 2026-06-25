require "json"
require "net/http"
require "uri"

module Veryfon
  class Client
    DEFAULT_BASE_URL = "https://veryfon.com"

    def initialize(api_key:, base_url: nil)
      @api_key  = api_key
      @base_url = (base_url || DEFAULT_BASE_URL).chomp("/")
    end

    def request_verification(phone:, qr_code: false)
      phone = normalize_phone(phone.to_s)

      raise ValidationError, "Phone must start with + (E.164 format)" unless phone.start_with?("+")
      raise ValidationError, "Phone must contain only digits after +" unless phone[1..].match?(/\A\d+\z/)

      body = { phone: phone }
      body[:qr_code] = true if qr_code

      resp = http_post("/verifications", body)
      Verification.new(resp)
    end

    def check_verification(id)
      resp = http_get("/verifications/#{URI.encode_www_form_component(id)}")
      Verification.new(resp)
    end

    def wait_for_verification(id, timeout: 300, interval: 2)
      deadline = Time.now + timeout

      loop do
        v = check_verification(id)
        return v if v.verified? || v.expired?

        raise TimeoutError, "Verification #{id} timed out after #{timeout}s" if Time.now >= deadline

        sleep interval
      end
    end

    private

    def normalize_phone(phone)
      phone.strip.gsub(/[\s\-\(\)\.]/, "")
    end

    def http_get(path)
      uri = URI("#{@base_url}#{path}")
      req = Net::HTTP::Get.new(uri)
      req["Authorization"] = "Bearer #{@api_key}"
      req["Accept"] = "application/json"
      send_request(uri, req)
    end

    def http_post(path, body)
      uri = URI("#{@base_url}#{path}")
      req = Net::HTTP::Post.new(uri)
      req["Authorization"] = "Bearer #{@api_key}"
      req["Content-Type"] = "application/json"
      req["Accept"] = "application/json"
      req.body = JSON.generate(body)
      send_request(uri, req)
    end

    def send_request(uri, req)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = 10
      http.read_timeout = 30

      res = http.start { http.request(req) }

      case res
      when Net::HTTPUnauthorized
        raise AuthenticationError, parse_error(res)
      when Net::HTTPNotFound
        raise NotFoundError, parse_error(res)
      when Net::HTTPUnprocessableEntity
        raise ValidationError, parse_error(res)
      when Net::HTTPSuccess
        JSON.parse(res.body)
      else
        raise Error, "HTTP #{res.code}: #{parse_error(res)}"
      end
    end

    def parse_error(res)
      JSON.parse(res.body)["error"] rescue "Unknown error"
    end
  end
end
