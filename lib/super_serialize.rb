module SuperSerialize
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
    def super_serialize(*attr_names)
      # === Arguments
      # +attr_names+:: the name of the of the attributes to be super_serialized
      # === Example
      #   class SomeModel < ActiveRecord::Base
      #     super_serialize :varied_attr_type, :other_varied_attr_type
      #   end
      #
      #   Attr type and class dynamically set based on the detected class type.
      #   Value can be set with objects or with strings that gets serialized to
      #   appropriate object via the YAML library
      #
      # === Example usage
      #   >  sm = SomeModel.new
      #   >  sm.varied_attr_type = 3
      #   >  sm.varied_attr_type
      #   => 3
      #   >  sm.varied_attr_type.class
      #   => Fixnum
      #   >  sm.varied_attr_type = "3"
      #   >  sm.varied_attr_type
      #   => 3
      #   >  sm.varied_attr_type.class
      #   => Fixnum
      #   >  sm.varied_attr_type = "3.0"
      #   >  sm.varied_attr_type
      #   => 3.0
      #   >  sm.varied_attr_type.class
      #   => Float
      #   >  sm.varied_attr_type = "some string"
      #   >  sm.varied_attr_type
      #   => "some string"
      #   >  sm.varied_attr_type.class
      #   => String
      #   >  sm.varied_attr_type = [1,2]
      #   >  sm.varied_attr_type
      #   => [1,2]
      #   >  sm.varied_attr_type.class
      #   => Array
      #   >  sm.varied_attr_type = "[1,2,3]"
      #   >  sm.varied_attr_type
      #   => [1,2]
      #   >  sm.varied_attr_type.class
      #   => Array
      #   >  sm.varied_attr_type = "{key: 'some value'}"
      #   >  sm.varied_attr_type
      #   => {"key" => 'some value'}
      #   >  sm.varied_attr_type.class
      #   => ActiveSupport::HashWithIndifferentAccess
      #   >  sm.varied_attr_type = {key: 'some value'}
      #   >  sm.varied_attr_type
      #   => {"key" => 'some value'}
      #   >  sm.varied_attr_type.class
      #   => ActiveSupport::HashWithIndifferentAccess
      #   >  sm.varied_attr_type = "2014-12-06 12:00:00 -0500"
      #   >  sm.varied_attr_type
      #   => 2014-12-06 12:00:00 -0500
      #   >  sm.varied_attr_type.class
      #   => Time
      #   >  sm.varied_attr_type = Time.parse("2014-12-06 12:00:00 -0500")
      #   >  sm.varied_attr_type
      #   => 2014-12-06 12:00:00 -0500
      #   >  sm.varied_attr_type.class
      #   => Time
      #   >  sm.varied_attr_type = "2014-12-06"
      #   >  sm.varied_attr_type
      #   => 2014-12-06 12:00:00 -0500
      #   >  sm.varied_attr_type.class
      #   => Date
      #   >  sm.varied_attr_type = Date.parse("2014-12-06")
      #   >  sm.varied_attr_type
      #   => 2014-12-06
      #   >  sm.varied_attr_type.class
      #   => Date

      attr_names.each do |attr_name|
        unless column_names.include?(attr_name.to_s)
          raise ArgumentError, ":#{attr_name} is not a valid column name for #{name}."
        end

        unless attr_name.is_a? Symbol
          raise ArgumentError, "Please pass in symbols as arguments."
        end
      end

      attr_names.each do |attr_name|
        class_eval <<-RUBY, __FILE__, __LINE__+1
          def #{attr_name}
            value = super
            return value.with_indifferent_access if value.is_a?(Hash)
            return value unless should_return_loaded_yaml?(value)

            object = YAML::load(value)
            object.is_a?(Hash) ? object.with_indifferent_access : object
          end

          def #{attr_name}=(value)
            current_changed_attributes = changed_attributes.dup

             # Sanitizing the input
            if value.is_a?(String)
              value.strip!

              if trying_to_serialize_a_hash?(value)
                value = attempt_to_sanitize_hash_syntax(value)
              elsif number_string_starting_with_zero?(value)
                value = value.to_yaml
              elsif value == ''
                value = nil
              end
            end

            return_value = super(value)

            if #{attr_name} == #{attr_name}_was
              @changed_attributes = current_changed_attributes
            end

            return_value
          end

          def #{attr_name}_was
            value = super

            if persisted? && is_valid_yaml?(value)
              YAML::load(value)
            else
              value
            end
          end
        RUBY
      end

      class_eval do
        # Validations for super serialized columns
        validate :check_if_super_serialized_attributes_are_valid_yaml

        # Callback to yamlize super serialized columngs just prior to saving to the database
        before_save :yamlize_super_serialized_attributes

        unless const_defined?('SUPER_SERIALIZED_ATTRIBUTES')
          const_set('SUPER_SERIALIZED_ATTRIBUTES', attr_names)
        end

        unless const_defined?('HASH_ROCKET_REGEX_MATCH')
          const_set('HASH_ROCKET_REGEX_MATCH',
            %r{
              # Do not match two colons next to each other.
              # This is the 1st group match
              ([^:])
              # This is technically the 2nd group match
              (
                # Match the old syntax symbol hash rocket key
                # 3rd group match
                :([a-zA-Z_][a-zA-Z_0-9]*)
                |
                # Match the single quote wrapped hash rocket key
                # 4th group match
                '([a-zA-Z_][a-zA-Z_0-9]*)'
                |
                # Match the double quote wrapped hash rocket key
                # 5th group match
                "([a-zA-Z_][a-zA-Z_0-9]*)"
              )
              \s*\=>\s*
            }x
          )
        end

        private

        def is_valid_yaml?(value)
          begin
            # because YAML::load('') returns false
            return true if value == ''

            !!YAML.load(value)
          rescue
            false
          end
        end

        def should_return_loaded_yaml?(value)
          return false if number_string_starting_with_zero?(value)
          return false if string_with_colons_and_not_hash_or_yaml?(value)
          is_valid_yaml?(value)
        end

        def number_string_starting_with_zero?(value)
          !!(value =~ /^0\d+\.*\d*$/)
        end

        # This is to take care of the following very specific scenario:
        # >  YAML::load("Note: something")
        # => {"Note"=>"something"}
        #
        # This is only an issue when the set value has not been saved to the DB
        def string_with_colons_and_not_hash_or_yaml?(value)
          # Value should be a string
          return false unless value.is_a?(String)

          # Stringified YAML starts with 3 dashes; ensure not already yamilified
          return false if !!(value =~ /\A---/)

          # Should be trying to serialize a hash
          return false if trying_to_serialize_a_hash?(value)

          # Should also be valid YAML
          return false unless is_valid_yaml?(value)

          # Check if the returned, loaded, valid YAML is a Hash.
          # If so, return string value.
          YAML::load(value).is_a?(Hash)
        end

        def trying_to_serialize_a_hash?(value)
          return false unless value.is_a?(String)
          !!(value =~ /\A{.+|.+}\Z/)
        end

        def attempt_to_sanitize_hash_syntax(value)
          value.gsub(self.class::HASH_ROCKET_REGEX_MATCH) do |string|
            "#{$1}#{($3 || $4 || $5)}: "
          end.gsub(/(:)([^\s])/, '\1 \2')
        end

        def yamlize_super_serialized_attributes
          self.class.const_get('SUPER_SERIALIZED_ATTRIBUTES').each do |attr_name|
            next unless send(attr_name)
            self.send("#{attr_name}=", send(attr_name).to_yaml)
          end
        end

        def super_serialized_attr_as_string_or_yaml(attr_name)
          if read_attribute(attr_name).is_a?(String)
            value = read_attribute(attr_name)
            trying_to_serialize_a_hash?(value) ? value : value.to_yaml
          else
            send(attr_name).to_yaml
          end
        end

        def check_if_super_serialized_attributes_are_valid_yaml
          self.class.const_get('SUPER_SERIALIZED_ATTRIBUTES').each do |attr_name|
            next unless send(attr_name)

            unless is_valid_yaml?(super_serialized_attr_as_string_or_yaml(attr_name))
              if trying_to_serialize_a_hash?(read_attribute(attr_name))
                errors.add(attr_name, 'syntax is incorrect if you are trying to save a hash. Example of a valid hash would be {some_key: "some value"}.')
              else
                errors.add(attr_name, 'could not be properly serialized. Typical serializations are numbers, strings, arrays, or hashes.')
              end
            end
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, SuperSerialize
