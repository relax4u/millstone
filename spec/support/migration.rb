require 'active_record'

# database connection
ActiveRecord::Base.configurations = {'test' => {:adapter => 'sqlite3', :database => ':memory:'}}
ActiveRecord::Base.establish_connection('test')

class CreateTestTables < ActiveRecord::Migration
  def self.up
    create_table :time_columns, :force => true do |t|
      t.string :context
      t.datetime :deleted_at
      t.timestamps
    end

    create_table :boolean_columns, :force => true do |t|
      t.string :context
      t.boolean :deleted
      t.timestamps
    end

    create_table :children, :force => true do |t|
      t.integer :parent_id
      t.string :context
      t.datetime :deleted_at
      t.timestamps
    end

    create_table :polymorphic_children, :force => true do |t|
      t.string :polymorphous_type
      t.integer :polymorphous_id
      t.string :context
      t.datetime :deleted_at
      t.timestamps
    end

    create_table :masters, :force => true do |t|
      t.string :context
      t.timestamps
    end

    create_table :havings, :force => true do |t|
      t.integer :parent_id
      t.integer :master_id
      t.datetime :deleted_at
      t.timestamps
    end

  end
end
