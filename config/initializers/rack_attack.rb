# config/initializers/rack_attack.rb

class Rack::Attack
  # Block requests from 10.0.0.0/8
  blocklist('block 10.0.0.0/8') do |req|
    IPAddr.new('10.0.0.0/8').include?(req.ip)
  end

  # Throttle requests to 100 requests per 10 minutes per IP
  throttle('req/ip', limit: 100, period: 10.minutes) do |req|
    req.ip
  end

  # Allow all local traffic
  safelist('allow-localhost') do |req|
    ['127.0.0.1', '::1'].include?(req.ip)
  end
end

Rails.application.config.middleware.use Rack::Attack
