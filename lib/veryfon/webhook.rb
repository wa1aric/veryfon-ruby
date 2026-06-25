require "json"
require "openssl"

module Veryfon
  module Webhook
    def self.verify(request_body, signature, secret)
      raise SignatureMismatchError, "Missing signature header" unless signature
      raise SignatureMismatchError, "Missing webhook secret" unless secret

      expected = OpenSSL::HMAC.hexdigest("SHA256", secret, request_body)

      unless secure_compare(expected, signature)
        raise SignatureMismatchError, "Signature does not match"
      end

      attrs = JSON.parse(request_body)
      Verification.new(attrs)
    end

    def self.secure_compare(a, b)
      return false unless a.respond_to?(:bytesize) && b.respond_to?(:bytesize)
      return false unless a.bytesize == b.bytesize

      result = 0
      a.bytes.zip(b.bytes) { |x, y| result |= x ^ y }
      result.zero?
    end

    private_class_method :secure_compare
  end
end
