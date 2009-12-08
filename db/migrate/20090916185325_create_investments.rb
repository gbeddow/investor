class CreateInvestments < ActiveRecord::Migration
  def self.up
    create_table :investments do |t|
      t.column :xml, :text
      t.timestamps
    end
  end

  def self.down
    drop_table :investments
  end
end
