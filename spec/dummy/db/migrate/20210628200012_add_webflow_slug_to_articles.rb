# frozen_string_literal: true

class AddWebflowSlugToArticles < ActiveRecord::Migration[6.1]
  def change
    add_column :articles, :webflow_slug, :string
  end
end
