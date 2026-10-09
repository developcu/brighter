# Homebrew distribution

The public tap is [developcu/homebrew-apps](https://github.com/developcu/homebrew-apps).

```sh
brew install --cask developcu/apps/brighter
```

The cask downloads the Developer ID signed, notarized ZIP from a versioned [GitHub Release](https://github.com/developcu/brighter/releases). It verifies SHA-256 and installs Brighter.app. It requires Apple silicon and macOS 14 or later. The built-in XDR requirement is also stated in the installation notice; CPU compatibility alone does not establish display compatibility.

To update or remove it:

```sh
brew update
brew upgrade --cask developcu/apps/brighter
brew uninstall --cask developcu/apps/brighter
```

If a manually installed Brighter.app already exists in Applications, quit it and move that copy elsewhere before installing with Homebrew. The cask does not overwrite an existing app by force.

## Publishing another release

1. Update application version/build values and verify the app on compatible hardware.
2. Build with Developer ID signing using scripts/build-app.sh and notarize using scripts/notarize.sh. These steps replace dist outputs: retain the previous release before running them.
3. Verify the **ZIP contents**, not just the source build: identifier, version, signature, staple, Gatekeeper and SHA-256.
4. Commit source and create a new version tag. Upload Brighter.zip to the matching GitHub Release. Do not replace an already published asset with different bytes at the same URL.
5. Update version and checksum in Casks/brighter.rb here and in developcu/homebrew-apps. Verify the two definitions match.
6. Run brew style and brew audit --cask --online for the tap cask. Install from its public download into an isolated app directory and verify the installed artifact before publishing the tap update.

For the first release, the retained direct build 1 predates the later UI/store packaging additions in main; see [release notes](releases/1.0.0.md). Future release tags should identify the exact source used to build their binary.
