class AddTrackersSeeInKanban < ActiveRecord::Migration
  def self.up
    add_column :trackers, :see_in_kanban, :boolean
  end

  def self.down
    remove_column :trackers, :see_in_kanban
  end
end

