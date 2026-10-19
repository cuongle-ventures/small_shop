module Activable
  extend ActiveSupport::Concern

  included do
    default_scope { where(active: true) }
  end
end