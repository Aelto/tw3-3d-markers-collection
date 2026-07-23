//! Possible performance improvements:
//! - Caching the local map pins and especially a pre-filtered list of all the
//!   fast travel pins.
//! - Re-using the same instance of the OL class instead of destroying & creating
//    new ones each time.

@addField(TDMC_Cache)
var fasttravel_oneliner: TDMCFT_Oneliner;

@wrapMethod(TDMC_Cache)
function initialize() {
  wrappedMethod();

  this.fasttravel_oneliner = new TDMCFT_Oneliner in this;
}

@wrapMethod(TDMC_Cache)
function cacheLocalMapPins() {
  var k: int;
  wrappedMethod();

  for (k = 0; k < this.merchants_oneliners.Size(); k += 1) {
    this.merchants_oneliners[k].updateMapPinsCache(this.local_map_pins);
  }
}

@wrapMethod(TDMC_Cache)
function onIntervalFast() {
  var player_position: Vector;
  var k: int;
  wrappedMethod();

  player_position = thePlayer.GetWorldPosition();
  for (k = 0; k < this.merchants_oneliners.Size(); k += 1) {
    this.merchants_oneliners[k].lookForCloserMapPin(player_position);
  }
}

@addMethod(W3PlayerWitcher)
timer function TDMCFT_delayOnelinerCreation(dt: float, id: int) {
  var position: Vector;
  var distance: float;
  var delay: float;

  position = TDMCFT_getClosestFastTravelPinPosition();

  SUOL_getManager().deleteByTagPrefix("TDMCFT");
  if (position.X != position.Y || position.X != 0.0) {
    (new TDMCFT_Oneliner in thePlayer).prepare(position);

    // use the distance to calculate how often it should search for new markers.
    // The further away from the marker the more often it runs, because as we
    // approach a marker the chances for us to get another marker that is closer
    // than the one we're approaching get smaller.
    distance = VecDistance2D(position, thePlayer.GetWorldPosition());

    // a base delay of 90 seconds,
    delay = 90.0f;
    // then for every 250 meters between us and the closest marker, remove 1 second.
    // At a distance of 500 meters the delay will be 20 seconds shorter.
    delay -= distance / 25.0;
    // it cannot check more often than every 30 seconds however.
    delay = MaxF(delay, 30);

    this.AddTimer('TDMCFT_delayOnelinerCreation', delay);
  }
  else {
    this.AddTimer('TDMCFT_delayOnelinerCreation', 20.0f);
  }
}

@wrapMethod(W3PlayerWitcher)
function OnSpawned(spawnData : SEntitySpawnData) {
  wrappedMethod(spawnData);

  this.AddTimer('TDMCFT_delayOnelinerCreation', 10.0f);
}

class TDMCFT_Oneliner extends TDMC_Oneliner {
  default tag = "TDMCFT";

  function prepare(position: Vector): TDMCFT_Oneliner {
    super.init(
      position + Vector(0, 0, 1.0),
      "<img src='img://icons/markers/icon_signpost.png' height='32' width='32' />"
    );

    this.register();
    return this;
  }
}

function TDMCFT_getClosestFastTravelPinPosition(): Vector {
  var local_map_pins: array<SCommonMapPinInstance>;
  var player_position: Vector;
  var distance: float;
  var k: int;

  var picked_pin_position: Vector;
  var picked_pin_distance: float;

  local_map_pins = theGame
      .GetCommonMapManager()
      .GetMapPinInstances(theGame.GetWorld().GetPath());

  player_position = thePlayer.GetWorldPosition();
  picked_pin_distance = -1;

  for (k = 0; k < local_map_pins.Size(); k += 1) {
    // early return: not a fast travel map pin,
    if (
      local_map_pins[k].type != 'RoadSign'
      && local_map_pins[k].type != 'Harbor'
    ) {
      continue;
    }

    // early return: too far,
    distance = VecDistanceSquared2D(local_map_pins[k].position, player_position);
    if (distance > 250 * 250) {
      continue;
    }

    // currently no picked pin, select the current one:
    if (picked_pin_distance < 0) {
      picked_pin_position = local_map_pins[k].position;
      picked_pin_distance = distance;
      continue;
    }

    // current pin is closer than the selected one, select it:
    if (distance < picked_pin_distance) {
      picked_pin_position = local_map_pins[k].position;
      picked_pin_distance = distance;
      continue;
    }
  }

  return picked_pin_position;
}
