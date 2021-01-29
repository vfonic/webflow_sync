class Article < ApplicationRecord
  include WebflowSync::ItemSync
end
