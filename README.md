![build](https://github.com/vfonic/webflow_sync/workflows/build/badge.svg)

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

## Contributing

PRs welcome!

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
