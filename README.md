# Ecommerce Backend API

A Ruby on Rails 8 API-only backend for e-commerce, using PostgreSQL and Active Storage for image uploads. Designed to work with a React frontend.

## Features
- Ruby on Rails 8 (API mode)
- PostgreSQL database
- Active Storage for image uploads
- MiniTest for testing
- `rack-cors` for CORS (React frontend)
- `rack-attack` for security/rate limiting

## Setup Instructions

### Prerequisites
- Ruby 3.3+
- Rails 8.x
- PostgreSQL

### Install dependencies
```bash
bundle install
```

### Database setup
```bash
rails db:create db:migrate
```

### Active Storage
Already installed and migrated. Configure your storage service in `config/storage.yml`.

### Run the test suite
```bash
rails test
```

### CORS
CORS is configured to allow requests from `localhost:3000` (React dev server). Update `config/initializers/cors.rb` for production domains.

### Security
`rack-attack` is enabled for basic throttling and IP blocklisting. Adjust rules in `config/initializers/rack_attack.rb`.

---

Feel free to extend this backend for your e-commerce needs!
