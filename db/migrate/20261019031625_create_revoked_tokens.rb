class CreateRevokedTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :revoked_tokens do |t|
      t.timestamps
    end
  end
end
