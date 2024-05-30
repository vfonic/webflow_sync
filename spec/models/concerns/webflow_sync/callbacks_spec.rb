# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WebflowSync::Callbacks do
  before(:each) do
    @skip_webflow_sync = WebflowSync.configuration.skip_webflow_sync
    WebflowSync.configuration.skip_webflow_sync = false
  end

  after(:each) do
    WebflowSync.configuration.skip_webflow_sync = @skip_webflow_sync # rubocop:disable RSpec/InstanceVariable
  end

  describe '#create_webflow_item', vcr: { cassette_name: 'webflow_sync/create_webflow_item' } do
    it 'enqueues Webflow item creation' do # rubocop:disable RSpec/ExampleLength
      article = build(:article)
      # we are hardcoding the id to 1, because we are only creating one article and, to make `article.save!` call on: :create callback,
      # we cannot save the record before, so we do
      article_id = 1

      expect do
        article.save!
      end.to have_enqueued_job(WebflowSync::CreateItemJob)
        .with(collection_id: article.webflow_collection_id, model_name: article.model_name.name, id: article_id)
    end
  end

  describe '#update_webflow_item', vcr: { cassette_name: 'webflow_sync/update_webflow_item' } do
    it 'enqueues Webflow item update' do
      article = create(:article)

      expect do
        article.update!(title: 'New title')
      end.to have_enqueued_job(WebflowSync::UpdateItemJob)
        .with(collection_id: article.webflow_collection_id, model_name: article.model_name.name, id: article.id)
    end
  end

  describe '#destroy_webflow_item', vcr: { cassette_name: 'webflow_sync/destroy_webflow_item', record: :new_episodes } do
    it 'enqueues Webflow item destroy' do # rubocop:disable RSpec/ExampleLength
      article = create(:article)

      expect do
        article.destroy!
      end.to have_enqueued_job(WebflowSync::DestroyItemJob).with(
        collection_id: article.webflow_collection_id, webflow_site_id: article.webflow_site_id, webflow_item_id: article.webflow_item_id
      )
    end
  end

  describe '#should_skip_webflow_sync?' do
    let(:article) { Article.new }

    context "when it shouldn't skip Webflow sync", vcr: { cassette_name: 'webflow_sync/should_skip_webflow_sync' } do
      it 'returns false' do
        expect(article.should_skip_webflow_sync?).to be false
      end
    end

    context 'when config.skip_webflow_sync is true' do
      before(:each) do
        WebflowSync.configuration.skip_webflow_sync = true
      end

      it 'returns true' do
        expect(article.should_skip_webflow_sync?).to be true
      end
    end

    context 'when record.skip_webflow_sync is true' do
      before(:each) do
        # need to do article.skip_webflow_sync = true but by opening the class
        # we can't call super so we need to override the method
        class << article
          def skip_webflow_sync = true
        end
      end

      it 'returns true' do
        expect(article.should_skip_webflow_sync?).to be true
      end
    end

    context 'when record.webflow_site_id is blank' do
      before(:each) do
        class << article
          def webflow_site_id = nil
        end
      end

      it 'returns true' do
        expect(article.should_skip_webflow_sync?).to be true
      end
    end

    context 'when record.webflow_collection_id is blank' do
      before(:each) do
        class << article
          def webflow_collection_id = nil
        end
      end

      it 'returns true' do
        expect(article.should_skip_webflow_sync?).to be true
      end
    end
  end
end
