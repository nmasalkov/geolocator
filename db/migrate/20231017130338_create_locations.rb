class CreateLocations < ActiveRecord::Migration[7.1]
  def change
    create_table :locations do |t|
      t.text :url
      t.text :ip_address, null: false
      # in the scope of the current app, two text/number fields for longitude and latitude would be enough
      # but if some features like "find IPs in given place" are planned, complex types may be easier to search and index
      t.point :geolocation, null: false

      t.timestamps
    end

    add_index :locations, :url, unique: true
    add_index :locations, :ip_address, unique: true
  end
end
