# SuperSerialize

A super, simple way to serialize anything from Fixnums and Floats to Arrays, Hashes, Times and Dates.

## Installation

Add this line to your application's Gemfile:

    gem 'super_serialize'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install super_serialize

## Usage

**In your model**

    class SomeModel < ActiveRecord::Base
      super_serialize :varied_attr_type, :other_varied_attr_type

      ...
    end

**Examples**:

    >  sm = SomeModel.new
    >  sm.varied_attr_type = 3
    >  sm.varied_attr_type
    => 3

    >  sm.varied_attr_type.class
    => Fixnum

    >  sm.varied_attr_type = "3"
    >  sm.varied_attr_type
    => 3

    >  sm.varied_attr_type.class
    => Fixnum

    >  sm.varied_attr_type = "3.0"
    >  sm.varied_attr_type
    => 3.0

    >  sm.varied_attr_type.class
    => Float

    >  sm.varied_attr_type = "some string"
    >  sm.varied_attr_type
    => "some string"

    >  sm.varied_attr_type.class
    => String

    >  sm.varied_attr_type = [1,2]
    >  sm.varied_attr_type
    => [1,2]

    >  sm.varied_attr_type.class
    => Array

    >  sm.varied_attr_type = "[1,2,3]"
    >  sm.varied_attr_type
    => [1,2]

    >  sm.varied_attr_type.class
    => Array

    >  sm.varied_attr_type = "{key: 'some value'}"
    >  sm.varied_attr_type
    => {"key" => 'some value'}

    >  sm.varied_attr_type.class
    => ActiveSupport::HashWithIndifferentAccess

    >  sm.varied_attr_type = {key: 'some value'}
    >  sm.varied_attr_type
    => {"key" => 'some value'}

    >  sm.varied_attr_type.class
    => ActiveSupport::HashWithIndifferentAccess

    >  sm.varied_attr_type = "2014-12-06 12:00:00 -0500"
    >  sm.varied_attr_type
    => 2014-12-06 12:00:00 -0500

    >  sm.varied_attr_type.class
    => Time

    >  sm.varied_attr_type = Time.parse("2014-12-06 12:00:00 -0500")
    >  sm.varied_attr_type
    => 2014-12-06 12:00:00 -0500

    >  sm.varied_attr_type.class
    => Time

    >  sm.varied_attr_type = "2014-12-06"
    >  sm.varied_attr_type
    => 2014-12-06 12:00:00 -0500

    >  sm.varied_attr_type.class
    => Date

    >  sm.varied_attr_type = Date.parse("2014-12-06")
    >  sm.varied_attr_type
    => 2014-12-06

    >  sm.varied_attr_type.class
    => Date

## Contributing

1. Fork it ( http://github.com/ricardo-quinones/super_serialize/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

This project rocks and uses MIT-LICENSE.