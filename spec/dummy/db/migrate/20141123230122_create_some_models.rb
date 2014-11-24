class CreateSomeModels < ActiveRecord::Migration
  def change
    create_table :some_models do |t|
      t.text :varied_attr_type

      t.timestamps
    end
  end
end
