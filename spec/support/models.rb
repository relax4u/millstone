require 'active_record'

# database connection
ActiveRecord::Base.configurations = {'test' => {:adapter => 'sqlite3', :database => ':memory:'}}
ActiveRecord::Base.establish_connection('test')

class CreateTestTables < ActiveRecord::Migration
  def self.up
    create_table :paranoid_time_columns, :force => true do |t|
      t.string :context
      t.datetime :deleted_at
      t.timestamps
    end

    create_table :paranoid_boolean_columns, :force => true do |t|
      t.string :context
      t.boolean :deleted
      t.timestamps
    end
  end
end

# models
class ParanoidTimeColumn < ActiveRecord::Base
  acts_as_paranoid
end

class ParanoidBooleanColumn < ActiveRecord::Base
  acts_as_paranoid :column => :deleted, :type => :boolean
end
