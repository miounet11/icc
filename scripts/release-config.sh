#!/usr/bin/env bash

# Canonical release/update configuration for icc.
# Source this file from release scripts and GitHub Actions shell steps.

export ICC_REPO_OWNER="miounet11"
export ICC_REPO_NAME="icc"
export ICC_REPO_SLUG="${ICC_REPO_OWNER}/${ICC_REPO_NAME}"
export ICC_REPO_URL="https://github.com/${ICC_REPO_SLUG}"
export ICC_SITE_URL="https://www.iccjk.com"

export ICC_APP_NAME="icc"
export ICC_APP_BUNDLE_NAME="icc.app"
export ICC_CLI_NAME="icc"
export ICC_HELPER_NAME="ghostty"

export ICC_RELEASE_TAG_PREFIX="v"
export ICC_RELEASE_DMG_NAME="icc-macos.dmg"
export ICC_NIGHTLY_DMG_NAME="icc-nightly-macos.dmg"
export ICC_NIGHTLY_APP_NAME="icc NIGHTLY"
export ICC_NIGHTLY_BUNDLE_ID="com.icc.app.nightly"

export ICC_STABLE_APPCAST_NAME="appcast.xml"
export ICC_NIGHTLY_APPCAST_NAME="appcast.xml"
export ICC_NIGHTLY_COMPAT_APPCAST_NAME="appcast-universal.xml"

export ICC_DOWNLOADS_BASE_URL="${ICC_SITE_URL}/downloads"
export ICC_DOWNLOADS_ARCHIVE_BASE_URL="${ICC_DOWNLOADS_BASE_URL}/archive"
export ICC_RELEASE_DOWNLOAD_URL="${ICC_DOWNLOADS_BASE_URL}/${ICC_RELEASE_DMG_NAME}"
export ICC_RELEASE_MANIFEST_URL="${ICC_DOWNLOADS_BASE_URL}/latest.json"
export ICC_REMOTE_DAEMON_BASE_URL="${ICC_DOWNLOADS_BASE_URL}/remote"
export ICC_STABLE_FEED_URL="${ICC_DOWNLOADS_BASE_URL}/${ICC_STABLE_APPCAST_NAME}"
export ICC_NIGHTLY_FEED_URL="${ICC_REPO_URL}/releases/download/nightly/${ICC_NIGHTLY_APPCAST_NAME}"

export ICC_RELEASE_NOTES_BASE_URL="${ICC_SITE_URL}/changelog"
export ICC_COMMIT_BASE_URL="${ICC_REPO_URL}/commit"
export ICC_DOCS_URL="${ICC_REPO_URL}#readme"
export ICC_ISSUES_URL="${ICC_REPO_URL}/issues"
export ICC_RELEASES_URL="${ICC_REPO_URL}/releases"

# Internal remote helper keeps the legacy name for compatibility.
export ICC_REMOTE_DAEMON_REPO="${ICC_REPO_SLUG}"

# Homebrew tap is optional for now. Keep empty to disable automation.
export ICC_HOMEBREW_TAP_REPOSITORY=""
