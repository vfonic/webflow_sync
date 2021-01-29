# frozen_string_literal: true

FactoryBot.define do
  factory :article do
    title { 'MyString' }
    description { 'MyText' }
    published_at { '2021-01-29 10:03:54' }
  end
end
