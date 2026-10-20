class CustomerService
  attr_reader :customer

  def initialize(customer)
    @customer = customer
  end

  def listing(params)
    @customers = Customer.paginate(params)
    @customers
  end

  def show(id)
    customer = Customer.find_by(id)
    customer
  end
end