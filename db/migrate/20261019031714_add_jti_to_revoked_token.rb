class AddJtiToRevokedToken < ActiveRecord::Migration[8.1]
  def change
    add_column :revoked_tokens, :jti, :string
  end
end
