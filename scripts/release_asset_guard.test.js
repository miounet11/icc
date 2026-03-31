"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");

const {
  IMMUTABLE_RELEASE_ASSETS,
  RELEASE_ASSET_GUARD_STATE,
  evaluateReleaseAssetGuard,
  immutableReleaseAssetsForTag,
  releaseDmgNameForTag,
} = require("./release_asset_guard");

test("marks guard as complete and skips build/upload when all immutable assets already exist", () => {
  const immutableAssets = immutableReleaseAssetsForTag("v1.0.5");
  const result = evaluateReleaseAssetGuard({
    existingAssetNames: [...immutableAssets, "notes.txt"],
    immutableAssetNames: immutableAssets,
  });

  assert.deepEqual(result.conflicts, immutableAssets);
  assert.deepEqual(result.missingImmutableAssets, []);
  assert.equal(result.guardState, RELEASE_ASSET_GUARD_STATE.COMPLETE);
  assert.equal(result.hasPartialConflict, false);
  assert.equal(result.shouldSkipBuildAndUpload, true);
  assert.equal(result.shouldSkipUpload, true);
});

test("marks guard as clear when immutable assets are not present", () => {
  const immutableAssets = immutableReleaseAssetsForTag("v1.0.5");
  const result = evaluateReleaseAssetGuard({
    existingAssetNames: ["notes.txt", "checksums.txt"],
    immutableAssetNames: immutableAssets,
  });

  assert.deepEqual(result.conflicts, []);
  assert.deepEqual(result.missingImmutableAssets, immutableAssets);
  assert.equal(result.guardState, RELEASE_ASSET_GUARD_STATE.CLEAR);
  assert.equal(result.hasPartialConflict, false);
  assert.equal(result.shouldSkipBuildAndUpload, false);
  assert.equal(result.shouldSkipUpload, false);
});

test("marks guard as partial when only some immutable assets exist", () => {
  const immutableAssets = immutableReleaseAssetsForTag("v1.0.5");
  const partialAssets = ["appcast.xml", "iccd-remote-manifest.json"];
  const result = evaluateReleaseAssetGuard({
    existingAssetNames: partialAssets,
    immutableAssetNames: immutableAssets,
  });

  assert.deepEqual(result.conflicts, partialAssets);
  assert.deepEqual(
    result.missingImmutableAssets,
    immutableAssets.filter((assetName) => !partialAssets.includes(assetName)),
  );
  assert.equal(result.guardState, RELEASE_ASSET_GUARD_STATE.PARTIAL);
  assert.equal(result.hasPartialConflict, true);
  assert.equal(result.shouldSkipBuildAndUpload, false);
  assert.equal(result.shouldSkipUpload, false);
});

test("derives the release dmg name from a tag", () => {
  assert.equal(releaseDmgNameForTag("v1.2.3"), "icc-v1.2.3-macos.dmg");
  assert.deepEqual(immutableReleaseAssetsForTag("v1.2.3"), [
    "icc-v1.2.3-macos.dmg",
    ...IMMUTABLE_RELEASE_ASSETS.filter((assetName) => !assetName.endsWith(".dmg")),
  ]);
});
