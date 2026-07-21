# expects a linux environment, if you're on windows you can use WSL to run
# the recipes.

release: release-purge release-prepare-dependencies release-prepare-dlc && release-zip
  cp -r mod3dmarkerscollection_activequest ./release/mods/
  cp -r mod3dmarkerscollection_fasttravels ./release/mods/

release-purge:
  rm -rf ./release
  mkdir ./release
  mkdir ./release/mods
  mkdir ./release/dlc

release-prepare-dlc:
  cp -r markerscollection_icons/packed/dlc ./release/dlc

release-prepare-dependencies:
  cp -r tw3-shared-utils/mod_sharedutils_oneliners ./release/mods/mod_sharedutils_oneliners

release-zip:
  cd release && zip -r mod3dmarkerscollection mods dlc

update-sharedutils:
  git submodule update --remote
