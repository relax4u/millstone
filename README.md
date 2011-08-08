# Millstone

ActiveRecord plugin which hides records instead of deleting them for Rails3

Millstone is extending ActiveRecord::Relation

## Credits

This plugin was inspired by [rails3_acts_as_paranoid](https://github.com/goncalossilva/rails3_acts_as_paranoid) and [acts_as_paranoid](http://github.com/technoweenie/acts_as_paranoid).

## Usage

    class User < ActiveRecord::Base
      millstone
    end

### Options

- :column => 'deleted_at'
- :type => 'time'

### Filtering

    User.all          # retrieves the non-deleted records
    User.only_deleted # retrieves the deleted records
    User.with_deleted # retrieves all records, deleted or not

### Real deletion

    user.destroy!
    user.delete_all!(conditions)

### Validation

    class User < ActiveRecord::Base
      acts_as_paranoid
      validates_uniqueness_of :name
    end

    User.create(:name => 'foo').destroy
    User.new(:name => 'foo').valid? #=> true


    class User < ActiveRecord::Base
      acts_as_paranoid
      validates_uniqueness_of_with_deleted :name
    end

    User.create(:name => 'foo').destroy
    User.new(:name => 'foo').valid? #=> false

### Status

    user = User.create(:name => 'foo')
    user.deleted? #=> false
    user.destroy
    User.with_deleted.first.deleted? #=> true

### Association options

    class Parent < ActiveRecord::Base
      acts_as_pranoid
      has_many :children
    end

    class Child < ActiveRecord::Base
      acts_as_paranoid
      belongs_to :parent
    end

    parent = Parent.create(:name => "foo")
    child = parent.children.create!(:name => "bar")
    parent.destroy
    child.parent # => nil
  

    class Child < ActiveRecord::Base
      acts_as_paranoid
      belongs_to :parent, :with_deleted => true
    end
 
    parent = Parent.create(:name => "foo")
    child = parent.children.create!(:name => "bar")
    parent.destroy
    child.parent #=> #<Parent ... deleted_at: deleted_time>
    child.parent.deleted? #=> true

Copyright © 2011 Yoshikazu Ozawa, released under the MIT license
