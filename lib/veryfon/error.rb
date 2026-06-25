module Veryfon
  class Error < StandardError; end
  class AuthenticationError < Error; end
  class NotFoundError < Error; end
  class ValidationError < Error; end
  class TimeoutError < Error; end
  class SignatureMismatchError < Error; end
end
