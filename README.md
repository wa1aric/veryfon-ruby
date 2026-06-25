# Veryfon

Ruby client for [Veryfon](https://veryfon.com) phone verification via missed call.

```ruby
gem "veryfon"
```

## Usage

```ruby
require "veryfon"

client = Veryfon::Client.new(api_key: "vf_live_...")

# Trigger a verification
v = client.request_verification(phone: "+37112345678", qr_code: true)
v.call_number   # => "+18005551234"
v.qr_code_url   # => "https://veryfon.com/qr/uuid.png"

# Check status
v = client.check_verification("verification-uuid")
v.verified?  # => true / false
v.status     # => "verified", "pending", "expired"

# Poll until done
v = client.wait_for_verification("verification-uuid", timeout: 300, interval: 2)
```

### Sinatra / Rails

Add an initializer:

```ruby
$veryfon = Veryfon::Client.new(api_key: ENV["VERYFON_API_KEY"])
```

## Webhooks

Veryfon sends a signed POST to your webhook URL when a verification completes.

### Setup

1. In your Veryfon project settings, copy the **Webhook secret**
2. Set it as `VERYFON_WEBHOOK_SECRET` in your app
3. Create a route to receive the webhook:

```ruby
# Sinatra
post "/webhooks/veryfon" do
  body   = request.body.read
  sig    = request.env["HTTP_X_VERYFON_SIGNATURE"]
  secret = ENV["VERYFON_WEBHOOK_SECRET"]

  v = Veryfon::Webhook.verify(body, sig, secret)
  # v.phone => "+37112345678"
  # v.status => "verified"

  # Mark user as verified in your DB
  200
rescue Veryfon::SignatureMismatchError
  halt 401, "Invalid signature"
end
```

```ruby
# Rails (config/routes.rb)
post "/webhooks/veryfon", to: "webhooks#veryfon"

# app/controllers/webhooks_controller.rb
class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def veryfon
    v = Veryfon::Webhook.verify(request.body.read,
                                request.headers["X-Veryfon-Signature"],
                                ENV["VERYFON_WEBHOOK_SECRET"])
    # ...
    head :ok
  rescue Veryfon::SignatureMismatchError
    head :unauthorized
  end
end
```

## Errors

| Exception | When |
|---|---|
| `Veryfon::AuthenticationError` | Invalid API key |
| `Veryfon::NotFoundError` | Verification ID not found |
| `Veryfon::ValidationError` | Invalid phone or request body |
| `Veryfon::TimeoutError` | `wait_for_verification` timed out |
| `Veryfon::SignatureMismatchError` | Webhook signature doesn't match |
| `Veryfon::Error` | Other API errors (network, 5xx, etc.) |

## Development

```bash
bin/setup
bundle exec ruby -Ilib -e "require 'veryfon'; puts Veryfon::VERSION"
```
