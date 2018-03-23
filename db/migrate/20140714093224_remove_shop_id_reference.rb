class RemoveShopIdReference < ActiveRecord::Migration
  def up
    execute "DELETE FROM schema_migrations WHERE VERSION=20130903091309"
  end
end
