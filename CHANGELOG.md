# Changelog

## Unreleased

* Made 04-server_contact_info.cfg.lua configurable with ENV variables. Fixes [#4](https://github.com/SaraSmiseth/prosody/issues/4).
* Made 03-e2e-policy.cfg.lua configurable with ENV variables. Fixes [#9](https://github.com/SaraSmiseth/prosody/issues/9).

## v1.1.1

* Updated to Prosody version [0.11.6](https://blog.prosody.im/prosody-0.11.6-released/).
* Replace "master" with "dev".

## v1.1.0

### New features

* Enable "announce" and "lastactivity" modules.
* Add PROSODY_ADMINS to specify who is an administrator. Fixes #7

### Breaking changes

* Move global ssl section to https_ssl and legacy_ssl_ssl section. It is only needed there. #3
  * <https://prosody.im/doc/ports#ssl_configuration>

As explained in the [README](https://github.com/SaraSmiseth/prosody#ssl-certificates) this setup uses automatic location to find your certs. This did not work correctly before this change. It just always used the main certificate defined with the global `ssl` config setting. This setting was removed and for the [services](https://prosody.im/doc/certificates#service_certificates) that do not use automatic location new global settings were introduced. These are `legacy_ssl_ssl` and `https_ssl`.

### Other changes

* Add badges to README. Fixes #5.
* Add link to official documentation on certificate permissions to README. Related to #3

## v1.0.0

* First version
