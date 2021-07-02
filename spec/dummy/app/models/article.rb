# frozen_string_literal: true

class Article < ApplicationRecord
  include WebflowSync::ItemSync

  def as_webflow_json
    {
      name: self.title,
    }
  end
end
