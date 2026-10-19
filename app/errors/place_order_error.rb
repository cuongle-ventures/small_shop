class PlaceOrderError < StandardError
  def initialize(message)
    super(message)
  end
end