# This migration comes from kitting (originally 20130625092815)
class AddCompartmentLayoutToKitMediaType < ActiveRecord::Migration
  def change
    add_column :kit_media_types, :compartment_layout, :string
  end
end
