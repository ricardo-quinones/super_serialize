module SuperSerialize
  extend ActiveSupport::Concern
 
  included do
    # Validations for super serialized columns
    validate :check_if_super_serialized_attributes_are_valid_yaml

    # Callback to yamlize super serialized columngs just prior to saving to the database
    before_save :yamlize_super_serialized_attributes
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
            return value unless is_valid_yaml?(value)

            object = YAML::load(value)
            object.is_a?(Hash) ? object.with_indifferent_access : object
          end

          def #{attr_name}=(value)
            current_changed_attributes = changed_attributes.dup
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
        unless const_defined?('SUPER_SERIALIZED_ATTRIBUTES')
          const_set('SUPER_SERIALIZED_ATTRIBUTES', attr_names)
        end

        private

        def is_valid_yaml?(value)
          begin
            !!YAML.load(value)
          rescue
            false
          end
        end

        def yamlize_super_serialized_attributes
          self.class.const_get('SUPER_SERIALIZED_ATTRIBUTES').each do |attr_name|
            next unless send(attr_name)
            self.send("#{attr_name}=", send(attr_name).to_yaml)
          end
        end

        def super_serialized_attr_as_string_or_yaml(attr_name)
          if read_attribute(attr_name).is_a?(String)
            read_attribute(attr_name)
          else
            send(attr_name).to_yaml
          end
        end

        def check_if_super_serialized_attributes_are_valid_yaml
          self.class.const_get('SUPER_SERIALIZED_ATTRIBUTES').each do |attr_name|
            next unless send(attr_name)
            unless is_valid_yaml?(super_serialized_attr_as_string_or_yaml(attr_name))
              errors.add(attr_name, 'could not be properly serialized. Typical serializations are numbers, strings, arrays, or hashes.')
            end
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, SuperSerialize
