# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20_210_628_200_012) do
  create_table 'articles', force: :cascade do |t|
    t.string 'title'
    t.text 'description'
    t.datetime 'published_at'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'webflow_item_id'
    t.string 'webflow_slug'
    t.index ['published_at'], name: 'index_articles_on_published_at'
  end
end
