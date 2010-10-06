class AddKanbanIssuesHitch < ActiveRecord::Migration
  def self.up
    add_column :kanban_issues, :hitch, :boolean
  end

  def self.down
    remove_column :kanban_issues, :hitch
  end
end

