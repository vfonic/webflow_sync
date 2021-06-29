[![Build Status](https://github.com/vfonic/webflow_sync/workflows/build/badge.svg)](https://github.com/vfonic/webflow_sync/actions)


# WebflowSync

Keep your Ruby on Rails records in sync with WebFlow.*

*Currently only one way Rails => WebFlow synchronization works

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'webflow_sync'
```

And then execute:

```bash
$ bundle
```

Then run the install generator:

```bash
bundle exec rails generate webflow_sync:install
```

## Usage

### Generate and set WebFlow API token

Run API token Rails generator and follow instructions:

```bash
bundle exec rails generate webflow_sync:api_token_flow
```
### Configuration options

In `config/initializers/webflow_sync.rb` you can specify configuration options:

1. `api_token`
2. `webflow_site_id`
3. `skip_webflow_sync` - skip synchronization for different environments
4. `sync_webflow_slug` - save slug generated on WebFlow to the Rails database, in the Rails model column. 

  This can be useful if you want to link to WebFlow item directly from your Rails app:

  ```rb
  link_to('View on site', "https://#{webflow_domain}/articles/#{record.webflow_slug}", target: :blank)
  ```

  To save slug generated on WebFlow in Rails model, `webflow_slug` column:

  1. add `webflow_slug` column on the model table, then
  2. set the `sync_webflow_slug` option to `true`.

  Example: 

  ```rb
  WebflowSync.configure do |config|
    config.skip_webflow_sync = ActiveModel::Type::Boolean.new.cast(ENV.fetch('SKIP_WEBFLOW_SYNC'))
    config.sync_webflow_slug = ActiveModel::Type::Boolean.new.cast(ENV.fetch('SYNC_WEBFLOW_SLUG'))
  end
  ```

### Add WebflowSync to models

For each model that you want to sync to WebFlow, you need to run the collection generator:

```bash
bundle exec rails generate webflow_sync:collection Article
```

Please note that this _does not_ create a WebFlow collection as that's not possible to do through WebFlow API.

### Create WebFlow collections

As mentioned above, you need to create the WebFlow collection yourself.

Make sure that the collection `slug` matches the Rails model collection name (the output of `model_class.model_name.collection`).

For example, for `Article` model:

```ruby
> Article.model_name.collection
# => "articles"
```

Your WebFlow collection `slug` should be `"articles"`.

### Set `webflow_site_id`

There are couple of ways how you can set the `webflow_site_id` to be used.

#### Set `webflow_site_id` through configuration

In `config/initializers/webflow_sync.rb` you can specify `webflow_site_id`:

```ruby
WebflowSync.configure do |config|
  config.webflow_site_id = ENV.fetch('WEBFLOW_SITE_ID')
end
```

#### Set `webflow_site_id` for each model individually

You can set `webflow_site_id` per model, or even per record.

To do this, override the `#webflow_site_id` method provided by `WebflowSync::ItemSync` in your ActiveRecord model.

For example, you could have `Site` model in your codebase:

```ruby
# app/models/site.rb
class Site < ApplicationRecord
  has_many :articles
end

# app/models/article.rb
class Article < ApplicationRecord
  include WebflowSync::ItemSync

  belongs_to :site

  def webflow_site_id
    self.site.webflow_site_id
  end
end
```

### Customize fields to synchronize

By default, WebflowSync calls `#as_webflow_json` on a record to get the fields that it needs to push to WebFlow. `#as_webflow_json` simply calls `#as_json` in its default implementation. To change this behavior, you can override `#as_json` in your model:

```ruby
# app/models/article.rb
class Article < ApplicationRecord
  include WebflowSync::ItemSync

  def as_json
    {
      title: self.title.capitalize,
      slug: self.title.parameterize,
      published_at: self.created_at,
      image: self.image_url
    }
  end
end
```

Or if you already use `#as_json` for some other use-case and cannot modify it, you can also override `#as_webflow_json` method. Here's the default `#as_webflow_json` implementation (you don't need to add this to your model):

```ruby
# app/models/article.rb
class Article < ApplicationRecord
  include WebflowSync::ItemSync
  
  def as_webflow_json
    self.as_json
  end
end
```

### Run the initial sync

After setting up which models you want to sync to WebFlow, you can run the initial sync for each of the models:

```ruby
WebflowSync::InitialSyncJob.perform_later('articles')
```

You can also run this from a Rake task:

```ruby
bundle exec rails "webflow_sync:initial_sync[articles]"
```

*Quotes are needed in order for this to work in all shells.

### Important note

This gem silently "fails" (does nothing) when `webflow_site_id` or `webflow_item_id` is `nil`! This is not always desired behavior so be aware of that.

## Contributing

PRs welcome!

## Thanks and Credits

This gem wouldn't be possible without the amazing work of [webflow-ruby](https://github.com/penseo/webflow-ruby) gem. Thank you, @phoet!


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
