class AddWebflowItemIdToArticles < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :webflow_item_id, :string
  end
end
