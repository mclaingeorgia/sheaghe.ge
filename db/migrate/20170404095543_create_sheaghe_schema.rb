class CreateSheagheSchema < ActiveRecord::Migration
  def change

    create_table :tags do |t|
      t.timestamps
    end

    create_table :service do |t|
      t.string :icon
      t.string :color

      t.timestamps
    end

    create_table :assets do |t|
      t.timestamps
    end

    create_table :providers do |t|
      t.timestamps

      t.references :user, index: true
    end

    create_table :places do |t|
      t.string :phone
      t.string :website
      t.integer :region
      t.decimal :latitude, precision: 8, scale: 5
      t.decimal :longitude, precision: 8, scale: 5
      t.decimal :rating

      t.timestamps
    end

    create_join_table :user, :places, :table_name => :user_places do |t|
      t.timestamps
      t.index [:place_id, :user_id]
    end

    create_join_table :provider, :users do |t|
      t.timestamps
      t.index [:provider_id, :user_id]
    end

    create_join_table :user, :place, :table_name => :rates do |t|
      t.timestamps
      t.integer :value
      t.index [:user_id, :place_id]
    end

    # create_table :moderation do |t| # report|ownership|new provider|tags
    #   t.integer :type
    #   t.integer :reported_by
    #   t.integer :related_id
    #   t.text :description
    #   t.integer :state
    # end
    reversible do |dir|
      dir.up do
        Place.create_translation_table! :name => :string, :description => :text, :address => :string, :village => :string, :city => :string
        Provider.create_translation_table! :name => :string, :description => :text
        Service.create_translation_table! :name => :string, :description => :text
      end

      dir.down do
        Provider.drop_translation_table!
        Place.drop_translation_table!
        Service.drop_translation_table!
      end
    end
  end
end

      # t.references :item, index: true
      # t.references :location, index: true