class SomeModel < ActiveRecord::Base
  attr_accessible :varied_attr_type

  super_serialize :varied_attr_type
end
