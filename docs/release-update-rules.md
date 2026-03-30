# Release And Update Rules

This file is the operator guide for future `icc` releases and upgrades.

## Source of truth

The control file is:

- `scripts/release-config.sh`

Keep all canonical release values there:

- GitHub repo slug
- stable and nightly feed URLs
- DMG names
- appcast file names
- nightly bundle ID
- release notes and commit URL prefixes

## Upgrade request addresses

Stable Sparkle feed:

- `https://www.iccjk.com/downloads/appcast.xml`

Nightly Sparkle feed:

- `https://github.com/miounet11/icc/releases/download/nightly/appcast.xml`

## Control files

Stable channel:

- `appcast.xml`
- `latest.json`

Nightly channel:

- `appcast.xml`
- `appcast-universal.xml`

Remote helper manifest:

- `https://www.iccjk.com/downloads/remote/cmuxd-remote-manifest.json`

Compatibility note:

- The remote helper and several manifest fields still use the legacy `cmuxd-remote` name. Do not rename those casually; they are part of the working remote bootstrap path.

## Asset naming rules

Stable release assets:

- `icc-macos.dmg`
- `appcast.xml`
- `latest.json`

Website-hosted archive copies:

- `downloads/archive/v1.0.4/icc-macos.dmg`
- `downloads/archive/v1.0.4/appcast.xml`

Website-hosted latest aliases:

- `downloads/icc-macos.dmg`
- `downloads/appcast.xml`
- `downloads/latest.json`

Nightly release assets:

- `icc-nightly-macos.dmg`
- `icc-nightly-macos-<build>.dmg`
- `appcast.xml`
- `appcast-universal.xml`

## Version rules

- Marketing version uses semantic versioning, for example `1.0.4`.
- Git tags must use the `v` prefix, for example `v1.0.4`.
- `CURRENT_PROJECT_VERSION` must remain monotonic for Sparkle.
- `scripts/bump-version.sh` should remain the normal way to set or bump versions.

## Current baseline

- Current public stable line: `v1.0.4`
- Repository: `https://github.com/miounet11/icc`

## Release workflow rules

1. Update `MARKETING_VERSION` to the target release, currently `1.0.4`.
2. Keep `CURRENT_PROJECT_VERSION` increasing even if the marketing version resets for branding reasons.
3. Build the signed and notarized macOS app, then generate `appcast.xml` with the matching Sparkle private key.
4. Stage the DMG, appcast, release manifest, and remote helper assets into `web/public/downloads` or the production site's `public/downloads` directory.
5. Deploy the website so `iccjk.com` serves the new DMG, `appcast.xml`, `latest.json`, and remote helper manifest.
6. Push the branch to `miounet11/icc`.
7. Create and push a tag such as `v1.0.4` after the website-hosted artifacts have been verified.

## Important migration note

Older internal builds used different repository identities and in some cases higher pre-release version strings. If a machine is already running one of those older internal builds, do one manual reinstall onto the first public `icc` release. After that, Sparkle can follow the new `icc` feed normally.
