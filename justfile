# expects a linux environment, if you're on windows you can use WSL to run
# the recipes.

release: release-purge release-prepare-dependencies && release-zip
  cp -r mod3dmarkerscollection_activequest ./release/mods/

release-purge:
  rm -rf ./release
  mkdir ./release
  mkdir ./release/mods

release-prepare-dependencies:
  cp -r tw3-shared-utils/mod_sharedutils_oneliners ./release/mods/mod_sharedutils_oneliners

release-zip:
  cd release && zip -r mod3dmarkerscollection mods

update-sharedutils:
  git submodule update --remote
