# frozen_string_literal: true

class Article < ApplicationRecord
  include WebflowSync::ItemSync
end
