# 8.0.0

- `WebflowSync::Api` rewrite.
- `webflow_sync` gem (this gem) now uses `webflow-rb` gem instead of `webflow-ruby` gem. This change was made to be able to use the latest version of `webflow-rb` gem which is actively maintained. It also supports Webflow API v2 and you no longer need to specify both `webflow_sync` and `webflow-ruby` gems in your Gemfile.

Before:

```ruby
gem 'webflow-ruby', github: 'vfonic/webflow-ruby', branch: 'api-v2'
gem 'webflow_sync'
```

After:

```ruby
gem 'webflow_sync'
```

- Refactor `WebflowSync` job classes: `WebflowSync::CreateItemJob`, `WebflowSync::UpdateItemJob`, `WebflowSync::DeleteItemJob` to use `collection_id` as a keyword argument as opposed to `collection_slug` as positional argument. When upgrading the gem, if you're not directly calling these jobs, you don't need to do anything. The gem will still use `collection_slug` to get the `collection_id`.

# 7.0.0

- Always check `WebflowSync.configuration.skip_webflow_sync` and `record.skip_webflow_sync` before syncing a record.
- When switching from create/update to update/create because of `webflow_item_id` already present/blank, enqueue the job instead of performing it inline. `return WebflowSync::CreateItemJob.perform_later(model_name, id, collection_slug) if record.webflow_item_id.blank?` instead of `return WebflowSync::CreateItemJob.perform_now(model_name, id, collection_slug) if record.webflow_item_id.blank?`. This helps to have the correct job visible on the queue in the jobs dashboard.

# 6.1.2

- Fix: Remove class methods that _do_ depend on `site_id` argument: `get_all_items`, `get_item`, `create_item`, `update_item`, `delete_item`

# 6.1.1

- Fix: Allow calling `WebflowSync::Api.new` without passing in `site_id` argument.
- Add class methods to `WebflowSync::Api` class for all methods that don't require `site_id` argument: `get_all_items`, `get_item`, `create_item`, `update_item`, `delete_item`, `sites`
- This allows us to call `WebflowSync::Api.new.sites` or even shorter `WebflowSync::Api.sites`.

# 6.1.0

- Make sure all Webflow API calls catch "Rate limit hit" error and retry
- Add `WebflowSync::Api.sites` method to allow fetching all Webflow sites with retrying on rate limiting

# 6.0.0

- As long as the error is `Rate limit hit`, sleep 10 seconds and retry the request
- Lower the Rails version requirement to >= 5.0
- Remove `WebFlow.configuration.publish_on_sync` config option. This is no longer needed. We rely on Webflow correctly updating collection items by sending `live='true'` parameter on every create/update/delete request.
- Call `WebflowSync::UpdateItemJob` in `WebflowSync::CreateItemJob` if record already contains `webflow_item_id`. This can sometimes happen when we create a record in Rails, then update the record, so now there are `WebflowSync::CreateItemJob` and `WebflowSync::UpdateItemJob` jobs for the record, and then for some reason, first `WebflowSync::CreateItemJob` job fails. (This can happen for example because `Rate limit hit` or some other Webflow API error.) `WebflowSync::UpdateItemJob` will then run before `WebflowSync::CreateItemJob` and it will call `WebflowSync::CreateItemJob`. After that, when the original `WebflowSync::CreateItemJob` runs, it will create another record and overwrite the `webflow_item_id` created by `WebflowSync::UpdateItemJob`.
- This gem currently only works with a fork of 'webflow-ruby': `gem 'webflow-ruby', github: 'vfonic/webflow-ruby', branch: 'allow-live-delete'`

# 5.0.0

- Require Rails >= 7.0

# 4.0.2

- Revert "Explicitly require Webflow::Client and Webflow::Error" (v4.0.2 is the same as v4.0.0)

# 4.0.1

- Explicitly require Webflow::Client and Webflow::Error

# 4.0.0

- Bump dependencies
- Require Ruby 3.1 (Ruby 3.x is only required because of the new syntax used in the gem code)

# 3.1.0

- Allow syncing Rails model with any WebFlow collection. It doesn't have to have collection `slug` that matches the Rails model name.

# 3.0.0

- Added `WebFlow.configuration.publish_on_sync` (`true` by default) config option. If `true`, after each sync, the gem will publish the site on all domains.
