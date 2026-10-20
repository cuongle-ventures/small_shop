# New Store

A JSON API for a small online store, built with Ruby on Rails 8.1 as a learning project. It covers customers with JWT authentication, products, and orders.

## Requirements

* Ruby 3.4.2 (see `.ruby-version`)
* SQLite 3

## Setup

```bash
bundle install
bin/rails db:prepare  # creates and migrates the development database
bin/rails server
```

The API runs on `http://localhost:3000`.

## Running the tests

```bash
bin/rails test
```

The test files exist but are still empty. Writing them is part of the roadmap below.

## Checks

```bash
bin/brakeman          # static security analysis
bin/bundler-audit     # known vulnerabilities in gems
bin/rubocop           # style
```

## Endpoints

| Method | Path                    | Description                          |
| ------ | ----------------------- | ------------------------------------ |
| POST   | `/login`                | Returns a JWT                        |
| POST   | `/logout`               | Revokes the current token            |
| GET    | `/customers`            | List customers (paginated)           |
| GET    | `/customers/:id`        | Show a customer                      |
| POST   | `/customers`            | Create a customer                    |
| PATCH  | `/customers/:id`        | Update a customer                    |
| DELETE | `/customers/:id`        | Delete a customer                    |
| GET    | `/products`             | List products (paginated)            |
| GET    | `/products/:id`         | Show a product                       |
| POST   | `/products`             | Create a product                     |
| PATCH  | `/products/:id`         | Update a product                     |
| DELETE | `/products/:id`         | Deactivate a product (soft delete)   |
| GET    | `/orders`               | List the current customer's orders   |
| GET    | `/orders/:id`           | Show an order                        |
| DELETE | `/orders/:id`           | Delete an order                      |
| POST   | `/orders/place_order`   | Place an order                       |

Authenticated endpoints expect `Authorization: Bearer <token>`.

## Roadmap

The project is a working API. It needs better security, validation and tests before new features.

### Phase 1: Security and correctness

- [ ] Stop returning `password_digest` in customer responses (index, show, create, update)
- [ ] Replace the string-interpolated `LIKE` query in `Paginate` with a bound parameter, and make the search work on each model's columns
- [ ] Remove logging of passwords (`sessions_controller.rb`) and tokens (`application_controller.rb`)
- [ ] Require authentication for product create, update and delete
- [ ] Allow public customer signup, and let a customer only read or change their own record
- [ ] Move the JWT secret to Rails credentials or an environment variable
- [ ] Return 401 for auth failures and rescue `JWT::DecodeError` instead of every exception

**Done when:** no response contains `password_digest`, the pagination query has no string interpolation, products and customers require login, and auth failures return 401.

### Phase 2: Validation and error handling

- [ ] Add model validations: presence, unique email, price and quantity greater than or equal to zero
- [ ] Add a unique index on `customers.email`
- [ ] Fix `Activable` so products with a `nil` `active` value are not hidden. Move it to `app/models/concerns`
- [ ] Add `rescue_from` in `ApplicationController` for not-found, missing parameters and custom errors
- [ ] Give every error response an explicit status code
- [ ] Use one response shape, for example `{ data: ... }` or `{ errors: [...] }`
- [ ] Handle customer deletion when the customer has orders

### Phase 3: Testing

- [ ] Test that `place_order` rolls back when a product is missing (write this first)
- [ ] Model tests for validations
- [ ] Request tests for each endpoint, including auth failures
- [ ] Add a `test` job to `.github/workflows/ci.yml`. Today CI runs only Brakeman, bundler-audit, importmap audit and RuboCop

### Phase 4: Data and queries

- [ ] Add `includes` to the order detail query to fix N+1 queries
- [ ] Whitelist `sort_column` and `direction` in pagination
- [ ] Fix pagination when `page` is 0 (the default), which currently produces a negative offset
- [ ] Add seed data in `db/seeds.rb`
- [ ] Validate order quantities

### Phase 5: Rails idioms and cleanup

- [ ] Replace the hand-written routes with `resources`. Make `place_order` a collection route
- [ ] Use Jbuilder views or `as_json(only: ...)` instead of building response hashes by hand
- [ ] Move order detail logic out of `OrdersController#show` into `OrderService`
- [ ] Replace the `Order` default scope with explicit scoping such as `current_customer.orders.find(...)`
- [ ] Remove the `currents` table and `Current` model if unused, the empty `customer_service` stub, the commented-out PWA routes, and debug logging
- [ ] Remove `allow_browser` from the API controller if it blocks API clients
- [ ] Rename the misleading migration `add_meta_data_reference_to_order_item`. Its name doesn't match what it does

### Phase 6: Beyond the basics

- [ ] Send confirmation emails from background jobs (Solid Queue is already in the Gemfile)
- [ ] Deploy with Kamal (`config/deploy.yml` is already present)
- [ ] API versioning and caching

## Learning resources

* [Rails Guides: Active Record Validations](https://guides.rubyonrails.org/active_record_validations.html)
* [Rails Guides: Testing Rails Applications](https://guides.rubyonrails.org/testing.html)
* [Rails Guides: Securing Rails Applications](https://guides.rubyonrails.org/security.html)
