class CreateUpstreamErrata < ActiveRecord::Migration
  def self.up
    create_table :upstream_errata do |t|
      t.string :errata_id
      t.string :title
      t.text :description, :limit => nil
      t.string :version
      t.string :release
      t.string :status
      t.date :updated
      t.date :issued
      t.string :from_str
      t.boolean :reboot_suggested
      t.string :references
      t.string :pkglist
      t.string :severity
      t.string :repoids
      t.string :engproduct_id
      t.timestamps
    end
  end

  def self.down
    drop_table :upstream_errata
  end
end
