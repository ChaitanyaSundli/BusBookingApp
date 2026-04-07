# Rack CORS Middleware Configuration
# Enable Cross-Origin Resource Sharing for frontend on localhost:5173

if defined?(Rack::Cors)
  Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      # Allow all variants of localhost:5173
      origins 'http://localhost:5173'
              

      resource '*',
        headers: :any,
        methods: [:get, :post, :put, :patch, :delete, :options, :head],
        credentials: true,
        max_age: 86400
    end
  end
end