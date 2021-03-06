require 'spec_helper'

describe SomeModel do
  let(:some_model) { SomeModel.new }

  describe ".super_serialize" do
    context "dealing with nil" do
      it "can save as a nil value" do
        some_model.save
        expect(some_model).to be_persisted
        expect(some_model.reload.varied_attr_type).to be_nil
      end
    end

    context "dealing with blank string" do
      it "saves a blank string as nil" do
        some_model.varied_attr_type = ''
        some_model.save
        expect(some_model).to be_persisted
        expect(some_model.reload.varied_attr_type).to eq(nil)
      end
    end

    context "a Fixnum" do
      context "new record" do
        it "sets the correct class when using an int" do
          some_model.varied_attr_type = 3
          expect(some_model.varied_attr_type).to eq(3)
          expect(some_model.varied_attr_type.class).to eq(Fixnum)
        end

        it "sets the correct class when using a string to represetn a fixnum" do
          some_model.varied_attr_type = "-1"
          expect(some_model.varied_attr_type).to eq(-1)
          expect(some_model.varied_attr_type.class).to eq(Fixnum)
        end
      end

      context "persisted record" do
        context "saving an int" do
          before(:each) do
            some_model.varied_attr_type = 3
            some_model.save
            some_model.reload
          end

          it "saves the attribute to the database as yaml" do
            expect(some_model.read_attribute(:varied_attr_type).class).to eq(String)
            expect(some_model.varied_attr_type).to eq(3)
            expect(some_model.varied_attr_type.class).to eq(Fixnum)
          end

          it "correctly sets the 'was' state of the attribute" do
            some_model.varied_attr_type = "string"
            expect(some_model.varied_attr_type).to eq('string')
            expect(some_model.varied_attr_type_was).to eq(3)
          end
        end

        context "saving a string as an int" do
          before(:each) do
            some_model.varied_attr_type = "3"
            some_model.save
            some_model.reload
          end

          it "saves the attribute to the database as yaml" do
            expect(some_model.read_attribute(:varied_attr_type).class).to eq(String)
            expect(some_model.varied_attr_type).to eq(3)
            expect(some_model.varied_attr_type.class).to eq(Fixnum)
          end

          it "correctly sets the 'was' state of the attribute" do
            some_model.varied_attr_type = "string"
            expect(some_model.varied_attr_type).to eq('string')
            expect(some_model.varied_attr_type_was).to eq(3)
          end

          it "correctly detects if the attribute has changed" do
            some_model.varied_attr_type = 3
            expect(some_model.varied_attr_type_changed?).to be_falsey
            some_model.varied_attr_type = "3"
            expect(some_model.varied_attr_type_changed?).to be_falsey
            some_model.varied_attr_type = "string"
            expect(some_model.varied_attr_type_changed?).to be_truthy
          end

          it "doesn't create changed_attributes" do
            some_model.varied_attr_type = 3
            expect(some_model.changed_attributes).to eq({})
            expect(some_model.changes).to eq({})
            expect(some_model.changed?).to be_falsey
          end
        end
      end
    end

    context "a Float" do
      it "sets the correct class when using a float" do
        some_model.varied_attr_type = 4.5
        expect(some_model.varied_attr_type).to eq(4.5)
        expect(some_model.varied_attr_type.class).to eq(Float)
      end

      it "sets the correct class when using a string to represent a float" do
        some_model.varied_attr_type = "-0.9"
        expect(some_model.varied_attr_type).to eq(-0.9)
        expect(some_model.varied_attr_type.class).to eq(Float)
      end

      context "persisted record" do
        context "saving a float" do
          before(:each) do
            some_model.varied_attr_type = 6.5
            some_model.save
            some_model.reload
          end

          it "saves the attribute to the database as yaml" do
            expect(some_model.read_attribute(:varied_attr_type).class).to eq(String)
            expect(some_model.varied_attr_type).to eq(6.5)
            expect(some_model.varied_attr_type.class).to eq(Float)
          end

          it "correctly sets the 'was' state of the attribute" do
            some_model.varied_attr_type = "string"
            expect(some_model.varied_attr_type).to eq('string')
            expect(some_model.varied_attr_type_was).to eq(6.5)
          end
        end

        context "saving a string as a float" do
          before(:each) do
            some_model.varied_attr_type = "-1.7"
            some_model.save
            some_model.reload
          end

          it "saves the attribute to the database as yaml" do
            expect(some_model.read_attribute(:varied_attr_type).class).to eq(String)
            expect(some_model.varied_attr_type).to eq(-1.7)
            expect(some_model.varied_attr_type.class).to eq(Float)
          end

          it "correctly sets the 'was' state of the attribute" do
            some_model.varied_attr_type = "string"
            expect(some_model.varied_attr_type).to eq('string')
            expect(some_model.varied_attr_type_was).to eq(-1.7)
          end
        end
      end
    end

    context "a String" do
      it "sets the correct class when using a string" do
        some_model.varied_attr_type = "I'm a string"
        expect(some_model.varied_attr_type).to eq("I'm a string")
        expect(some_model.varied_attr_type.class).to eq(String)
      end

      context "persisted record" do
        before(:each) do
          some_model.varied_attr_type = 'some string'
          some_model.save
          some_model.reload
        end

        it "saves the attribute to the database as yaml" do
          expect(some_model.read_attribute(:varied_attr_type).class).to eq(String)
          expect(some_model.varied_attr_type).to eq('some string')
          expect(some_model.varied_attr_type.class).to eq(String)
        end

        it "correctly sets the 'was' state of the attribute" do
          some_model.varied_attr_type = [1,2]
          expect(some_model.varied_attr_type).to eq([1,2])
          expect(some_model.varied_attr_type_was).to eq('some string')
        end

        it "correctly yamlizes a number string with zeros at the beginning" do
          some_model.varied_attr_type = '0123456789'
          expect(some_model.varied_attr_type.class).to eq(String)
          expect(some_model.varied_attr_type).to eq('0123456789')
          some_model.varied_attr_type = '0123456789.1234'
          expect(some_model.varied_attr_type.class).to eq(String)
          expect(some_model.varied_attr_type).to eq('0123456789.1234')
        end
      end
    end

    context "an Array" do
      let(:array) { [1, 'test', {hash: 1}] }
      let(:string_array) { "[1, 'test', {hash: 1}]" }

      it "sets the correct class when using an array" do
        some_model.varied_attr_type = array
        expect(some_model.varied_attr_type).to eq(array)
        expect(some_model.varied_attr_type.class).to eq(Array)
      end

      it "sets the correct class when using a string to represent an array" do
        some_model.varied_attr_type = string_array
        expect(some_model.varied_attr_type).to eq([1, 'test', {"hash" => 1}])
        expect(some_model.varied_attr_type.class).to eq(Array)
      end

      context "persisted record" do
        context "saving an array" do
          before(:each) do
            some_model.varied_attr_type = array
            some_model.save
            some_model.reload
          end

          it "saves the attribute to the database as yaml" do
            expect(some_model.read_attribute(:varied_attr_type).class).to eq(String)
            expect(some_model.varied_attr_type).to eq(array)
            expect(some_model.varied_attr_type.class).to eq(Array)
          end

          it "correctly sets the 'was' state of the attribute" do
            some_model.varied_attr_type = "string"
            expect(some_model.varied_attr_type).to eq('string')
            expect(some_model.varied_attr_type_was).to eq(array)
          end
        end

        context "saving a string as an array" do
          before(:each) do
            some_model.varied_attr_type = string_array
            some_model.save
            some_model.reload
          end

          it "saves the attribute to the database as yaml" do
            expect(some_model.read_attribute(:varied_attr_type).class).to eq(String)
            expect(some_model.varied_attr_type).to eq([1, 'test', {"hash" => 1}])
            expect(some_model.varied_attr_type.class).to eq(Array)
          end

          it "correctly sets the 'was' state of the attribute" do
            some_model.varied_attr_type = "string"
            expect(some_model.varied_attr_type).to eq('string')
            expect(some_model.varied_attr_type_was).to eq([1, 'test', {"hash" => 1}])
          end
        end
      end
    end

    context "a Hash e.g. an ActiveSupport::HashWithIndifferentAccess" do
      let(:hash) { {first_key: 1, second_key: [1, 'test', {"thing1" => 9}], float: -0.8}.with_indifferent_access }
      let(:string_hash) { "{first_key: 1, second_key: [1, 'test', {thing1: 9}], float: -0.8 }" }
      let(:actual_hash) { {first_key: 1, second_key: [1, 'test', {"thing1" => 9}], float: -0.8}.with_indifferent_access }
      let(:hash_rocket_hash) { {"first_key" => 1, "second_key" => [1, 'test', {"thing1" => 9}], float: -0.8} }
      let(:hash_rocket_hash_string) { '{ "first_key" => 1, "second_key" => [1, "test", {"thing1" => 9}], float: -0.8}' }

      context 'new syntax hash' do
        it "sets the correct class when using a new syntax hash" do
          some_model.varied_attr_type = hash
          expect(some_model.varied_attr_type).to eq(hash)
          expect(some_model.varied_attr_type.class).to eq(ActiveSupport::HashWithIndifferentAccess)
        end

        it "sets the correct class when using a string to represent a new syntax hash" do
          some_model.varied_attr_type = string_hash
          expect(some_model.varied_attr_type).to eq(actual_hash)
          expect(some_model.varied_attr_type.class).to eq(ActiveSupport::HashWithIndifferentAccess)
        end
      end

      context 'hash rocket syntax hash' do
        it "sets the correct class when using a hash-rocket-syntax hash" do
          some_model.varied_attr_type = hash_rocket_hash
          expect(some_model.varied_attr_type).to eq(hash_rocket_hash.with_indifferent_access)
          expect(some_model.varied_attr_type.class).to eq(ActiveSupport::HashWithIndifferentAccess)
        end

        it "sets the correct class when using a string to represent a hash-rocket-syntax hash" do
          some_model.varied_attr_type = hash_rocket_hash
          expect(some_model.varied_attr_type).to eq(actual_hash)
          expect(some_model.varied_attr_type.class).to eq(ActiveSupport::HashWithIndifferentAccess)
        end
      end

      context "persisted record" do
        context 'hash with hash at end' do
          it "does not mistake a yamlized hash as an attempt to serialize a hash" do
            h = { base_url: '/users/{{user_id}}', action: 'edit_hours', params: {} }
            some_model.varied_attr_type = h
            some_model.save
            some_model.reload
            expect(some_model.varied_attr_type).to eq(h.with_indifferent_access)
            expect(some_model.varied_attr_type.class).to eq(ActiveSupport::HashWithIndifferentAccess)
          end
        end

        context "saving a hash" do
          before(:each) do
            some_model.varied_attr_type = hash
            some_model.save
            some_model.reload
          end

          it "saves the attribute to the database as yaml" do
            expect(some_model.read_attribute(:varied_attr_type).class).to eq(String)
            expect(some_model.varied_attr_type).to eq(hash)
            expect(some_model.varied_attr_type.class).to eq(ActiveSupport::HashWithIndifferentAccess)
          end

          it "correctly sets the 'was' state of the attribute" do
            some_model.varied_attr_type = "string"
            expect(some_model.varied_attr_type).to eq('string')
            expect(some_model.varied_attr_type_was).to eq(hash)
          end
        end

        context "saving a string as a hash" do
          before(:each) do
            some_model.varied_attr_type = string_hash
            some_model.save
            some_model.reload
          end

          it "saves the attribute to the database as yaml" do
            expect(some_model.read_attribute(:varied_attr_type).class).to eq(String)
            expect(some_model.varied_attr_type).to eq(actual_hash)
            expect(some_model.varied_attr_type.class).to eq(ActiveSupport::HashWithIndifferentAccess)
          end

          it "correctly sets the 'was' state of the attribute" do
            some_model.varied_attr_type = "string"
            expect(some_model.varied_attr_type).to eq('string')
            expect(some_model.varied_attr_type_was).to eq(actual_hash)
          end
        end
      end
    end

    context "a Time" do
      let(:time_string) { "2014-06-30 12:00:00 -0500" }
      let(:time) { Time.parse(time_string) }

      it "sets the correct class when using a Time object" do
        some_model.varied_attr_type = time
        expect(some_model.varied_attr_type).to eq(time)
        expect(some_model.varied_attr_type.class).to eq(Time)
      end

      it "sets the correct class when using a string to a time" do
        some_model.varied_attr_type = time_string
        expect(some_model.varied_attr_type).to eq(time)
        expect(some_model.varied_attr_type.class).to eq(Time)
      end

      context "persisted record" do
        context "saving a time object" do
          before(:each) do
            some_model.varied_attr_type = time
            some_model.save
            some_model.reload
          end

          it "saves the attribute to the database as yaml" do
            expect(some_model.read_attribute(:varied_attr_type).class).to eq(String)
            expect(some_model.varied_attr_type).to eq(time)
            expect(some_model.varied_attr_type.class).to eq(Time)
          end

          it "correctly sets the 'was' state of the attribute" do
            some_model.varied_attr_type = "string"
            expect(some_model.varied_attr_type).to eq('string')
            expect(some_model.varied_attr_type_was).to eq(time)
          end
        end

        context "saving a time string" do
          before(:each) do
            some_model.varied_attr_type = time_string
            some_model.save
            some_model.reload
          end

          it "saves the attribute to the database as yaml" do
            expect(some_model.read_attribute(:varied_attr_type).class).to eq(String)
            expect(some_model.varied_attr_type).to eq(time)
            expect(some_model.varied_attr_type.class).to eq(Time)
          end

          it "correctly sets the 'was' state of the attribute" do
            some_model.varied_attr_type = "string"
            expect(some_model.varied_attr_type).to eq('string')
            expect(some_model.varied_attr_type_was).to eq(time)
          end
        end
      end
    end

    context "a Date" do
      let(:date_string) { "2014-06-30" }
      let(:date) { Date.parse(date_string) }

      it "sets the correct class when using a Time object" do
        some_model.varied_attr_type = date
        expect(some_model.varied_attr_type).to eq(date)
        expect(some_model.varied_attr_type.class).to eq(Date)
      end

      it "sets the correct class when using a string to a time" do
        some_model.varied_attr_type = date_string
        expect(some_model.varied_attr_type).to eq(date)
        expect(some_model.varied_attr_type.class).to eq(Date)
      end

      context "persisted record" do
        context "saving a time object" do
          before(:each) do
            some_model.varied_attr_type = date
            some_model.save
            some_model.reload
          end

          it "saves the attribute to the database as yaml" do
            expect(some_model.read_attribute(:varied_attr_type).class).to eq(String)
            expect(some_model.varied_attr_type).to eq(date)
            expect(some_model.varied_attr_type.class).to eq(Date)
          end

          it "correctly sets the 'was' state of the attribute" do
            some_model.varied_attr_type = "string"
            expect(some_model.varied_attr_type).to eq('string')
            expect(some_model.varied_attr_type_was).to eq(date)
          end
        end

        context "saving a time string" do
          before(:each) do
            some_model.varied_attr_type = date_string
            some_model.save
            some_model.reload
          end

          it "saves the attribute to the database as yaml" do
            expect(some_model.read_attribute(:varied_attr_type).class).to eq(String)
            expect(some_model.varied_attr_type).to eq(date)
            expect(some_model.varied_attr_type.class).to eq(Date)
          end

          it "correctly sets the 'was' state of the attribute" do
            some_model.varied_attr_type = "string"
            expect(some_model.varied_attr_type).to eq('string')
            expect(some_model.varied_attr_type_was).to eq(date)
          end
        end
      end
    end

    context "errors" do
      it "shows an error when the text cannot be properly serialized" do
        some_model.varied_attr_type = "{no_bueno_hash: 12342134"
        expect(some_model).to_not be_valid
        expect(some_model.errors.full_messages.first).to match('Varied attr type syntax is incorrect if you are trying to save a hash. Example of a valid hash would be {some_key: "some value"}.')
      end

      it "shows a hash specific error when trying to set the value to be a hash" do
        some_model.varied_attr_type = "{no-bueno-hash{:12342134} "
        expect(some_model).to_not be_valid
        expect(some_model.errors.full_messages.first).to match('Varied attr type syntax is incorrect if you are trying to save a hash. Example of a valid hash would be {some_key: "some value"}.')
      end
    end

    it "strips ending and leading white space if setting a string" do
      some_model.varied_attr_type = " Some string "
      expect(some_model.varied_attr_type).to eq("Some string")
      some_model.varied_attr_type = "   {test: 1} "
      expect(some_model.varied_attr_type.class).to eq(ActiveSupport::HashWithIndifferentAccess)
      expect(some_model.varied_attr_type).to eq({test: 1}.with_indifferent_access)
      some_model.varied_attr_type = "[1, '2']   "
      expect(some_model.varied_attr_type.class).to eq(Array)
      expect(some_model.varied_attr_type).to eq([1, '2'])
    end
  end

  describe "#attempt_to_sanitize_hash_syntax" do
    context 'symbolized hash rocket string' do
      it "reformats the hash to the new symbolized hash syntax" do
        hash_string = "{ :test => 1 }"
        expect(some_model.send(:attempt_to_sanitize_hash_syntax, hash_string)).to eq("{ test: 1 }")
        hash_string = "{ :test=> 1 }"
        expect(some_model.send(:attempt_to_sanitize_hash_syntax, hash_string)).to eq("{ test: 1 }")
        hash_string = "{ 'test' => 1}"
        expect(some_model.send(:attempt_to_sanitize_hash_syntax, hash_string)).to eq("{ test: 1}")
        hash_string = "{ 'test'=> 1 }"
        expect(some_model.send(:attempt_to_sanitize_hash_syntax, hash_string)).to eq("{ test: 1 }")
        hash_string = "{ 'test' =>1 }"
        expect(some_model.send(:attempt_to_sanitize_hash_syntax, hash_string)).to eq("{ test: 1 }")
        hash_string = "{\"test\" =>1 }"
        expect(some_model.send(:attempt_to_sanitize_hash_syntax, hash_string)).to eq("{test: 1 }")
      end

      it "correctly serializes plain text with one colon in it" do
        text = "Note: with a colon"
        some_model.varied_attr_type = text
        expect(some_model.varied_attr_type).to eq(text)
        some_model.save
        expect(some_model).to be_persisted
        expect(some_model.varied_attr_type).to eq(text)
      end

      it "correctly serializes plain text with multiple colons in it" do
        text = "Note: with a colon And: another colon"
        some_model.varied_attr_type = text
        expect(some_model.varied_attr_type).to eq(text)
        some_model.save
        expect(some_model).to be_persisted
        expect(some_model.varied_attr_type).to eq(text)
      end
    end
  end
end
