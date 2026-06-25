module Veryfon
  class Verification
    attr_reader :id, :phone, :status, :call_number, :qr_code_url,
                :credits_remaining, :created_at, :expires_at, :verified_at

    def initialize(attrs)
      @id               = attrs["verification_id"] || attrs[:verification_id] || attrs["id"]
      @phone            = attrs["phone"]
      @status           = attrs["status"]
      @call_number      = attrs["call_number"] || attrs["call_phone"]
      @qr_code_url      = attrs["qr_code_url"]
      @credits_remaining = attrs["credits_remaining"]
      @created_at       = attrs["created_at"]
      @expires_at       = attrs["expires_at"]
      @verified_at      = attrs["verified_at"]
    end

    def verified?
      status == "verified"
    end

    def pending?
      status == "pending"
    end

    def expired?
      status == "expired"
    end
  end
end
