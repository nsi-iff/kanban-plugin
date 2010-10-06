class AddIssuesHitch < ActiveRecord::Migration
  def self.up
    add_column :issues, :hitch, :boolean
  end

  def self.down
    remove_column :issues, :hitch
  end
end

