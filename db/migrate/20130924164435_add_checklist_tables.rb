# myExperiment: db/migrate/20130924164435_add_checklist_tables.rb
#
# Copyright (c) 2007-2013 The University of Manchester, the University of
# Oxford, and the University of Southampton.  See license.txt for details.

class AddChecklistTables < ActiveRecord::Migration
  def self.up
    create_table "checklist_results", :force => true do |t|
      t.integer "research_object_id"
      t.integer "score"
      t.integer "max_score"
      t.string  "minim_url"
      t.string  "purpose"

      t.timestamps
    end

    create_table "checklist_item_results", :force => true do |t|
      t.integer "checklist_result_id"
      t.string  "colour"
      t.string  "text"
    end
  end

  def self.down
    drop_table :checklist_item_results
    drop_table :checklist_results
  end
end