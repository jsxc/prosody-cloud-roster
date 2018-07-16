# mod_roster_cloud
Take your Nextcloud groups to your XMPP client.

## How to install
1. Download all lua files and move them to e.g. `/usr/lib/prosody/modules/mod_roster_cloud/`.
2. Add `roster_cloud` to your `modules_enabled` section in your prosody configuration.
3. Add `roster_cloud_url` and `roster_cloud_secret` to your prosody configuration with the values provided by [jsxc.nextcloud](https://github.com/nextcloud/jsxc.nextcloud) on your Nextcloud admin page. They correspond to *API URL* and *Secure API Token* in the Nextcloud JSXC settings.
4. Restart prosody.
