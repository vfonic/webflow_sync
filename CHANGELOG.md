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
