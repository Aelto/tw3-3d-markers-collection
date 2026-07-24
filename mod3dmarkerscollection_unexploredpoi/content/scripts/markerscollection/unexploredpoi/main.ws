@addField(TDMC_Cache)
var unexploredpoi_oneliners: array<TDMCUP_Oneliner>;

@addField(TDMC_Cache)
var unexploredpoi_pins: array<Vector>;


@wrapMethod(TDMC_Cache)
function initialize() {
  wrappedMethod();

  this.unexploredpoi_oneliners.PushBack((new TDMCUP_Oneliner in this).prepare());
  this.unexploredpoi_oneliners.PushBack((new TDMCUP_Oneliner in this).prepare());
  this.unexploredpoi_oneliners.PushBack((new TDMCUP_Oneliner in this).prepare());
  this.unexploredpoi_oneliners.PushBack((new TDMCUP_Oneliner in this).prepare());
}

@wrapMethod(TDMC_Cache)
function cacheLocalMapPins() {
  var k: int;
  wrappedMethod();

  for (k = 0; k < this.local_map_pins.Size(); k += 1) {
    if (
      local_map_pins[k].isDiscovered || local_map_pins[k].isDisabled
      || !(
           local_map_pins[k].type == 'Entrance'
           || local_map_pins[k].type == 'MonsterNest'
           || local_map_pins[k].type == 'InfestedVineyard'
           || local_map_pins[k].type == 'PlaceOfPower'
           || local_map_pins[k].type == 'TreasureHuntMappin'
           || local_map_pins[k].type == 'SpoilsOfWar'
           || local_map_pins[k].type == 'BanditCamp'
           || local_map_pins[k].type == 'BanditCampfire'
           || local_map_pins[k].type == 'BossAndTreasure'
           || local_map_pins[k].type == 'Contraband'
           || local_map_pins[k].type == 'ContrabandShip'
           || local_map_pins[k].type == 'RescuingTown'
           || local_map_pins[k].type == 'DungeonCrawl'
           || local_map_pins[k].type == 'Hideout'
           || local_map_pins[k].type == 'Plegmund'
           || local_map_pins[k].type == 'KnightErrant'
           || local_map_pins[k].type == 'WineContract'
           || local_map_pins[k].type == 'SignalingStake'
      )
    ) {
      continue;
    }

    this.unexploredpoi_pins.PushBack(local_map_pins[k].position);
  }
}

@wrapMethod(TDMC_Cache)
function onIntervalFast() {
  wrappedMethod();
  TDMCUP_updateUnexploredPoiPins(TDMC_CacheGet());

}

@wrapMethod(CCommonMapManager)
function SetEntityMapPinDiscoveredScript(
  isFastTravelPoint: bool,
  tag: name,
  optional set: bool
) {
  wrappedMethod(isFastTravelPoint, tag, set);
  TDMCUP_updateUnexploredPoiPins(TDMC_CacheGet());
}

function TDMCUP_updateUnexploredPoiPins(cache: TDMC_Cache) {
  var pins_by_cardinal: array<Vector>;
  var k: int;

  pins_by_cardinal = TDMCUP_getPinsByCardinalDirection(cache.unexploredpoi_pins);
  for (k = 0; k < pins_by_cardinal.Size(); k += 1) {
    if (pins_by_cardinal[k].X == 0 && pins_by_cardinal[k].Y == 0) {
      continue;
    }

    cache.unexploredpoi_oneliners[k].position = pins_by_cardinal[k];
    cache.unexploredpoi_oneliners[k].register();
  }
}

function TDMCUP_getPinsByCardinalDirection(
  pin_positions: array<Vector>
): array<Vector> {
  var player_position: Vector;
  var distance: float;
  var k, j: int;

  var picked_pins_by_cardinal: array<Vector>;
  var direction: Vector;
  var angle: float;
  var cardinal_index: int;

  var pins_by_cardinal: array<array<Vector>>;
  var picked_pin_distance: float;
  var picked_pin: Vector;

  player_position = thePlayer.GetWorldPosition();
  pins_by_cardinal.Grow(4);

  // 1) organize the pins by cardinal direction compared to the player
  for (k = 0; k < pin_positions.Size(); k += 1) {
    direction = player_position - pin_positions[k];
    angle = AngleNormalize(VecHeading(direction));

    // by diving the [0;360] range by 90, we get values in the [0;4[ range which
    // can be used as an index in an array
    cardinal_index = FloorF(angle / 90.0);

    // LogChannel('TDMCUP', "add pin to cardinal " + cardinal_index);
    pins_by_cardinal[cardinal_index].PushBack(pin_positions[k]);
  }

  // 2) for each cardinal direction, pick the closest pin then group them in a
  // single final array
  for (k = 0; k < pins_by_cardinal.Size(); k += 1) {
    picked_pin_distance = -1;

    for (j = 0; j < pins_by_cardinal[k].Size(); j += 1) {
      distance = VecDistanceSquared2D(player_position, pins_by_cardinal[k][j]);

      if (picked_pin_distance < 0 || distance < picked_pin_distance) {
        picked_pin = pins_by_cardinal[k][j];
        picked_pin_distance = distance;
      }
    }

    if (picked_pin_distance > 10) {
      picked_pins_by_cardinal.PushBack(picked_pin);
    }
  }

  return picked_pins_by_cardinal;
}

class TDMCUP_Oneliner extends TDMC_Oneliner {
  default tag = "TDMCUP";

  function prepare(): TDMCUP_Oneliner {
    this.text = "<img src='img://icons/markers/icon_point_of_interest.png' height='32' width='32' />";
    this.offset = Vector(0, 0, 5.0);

    return this;
  }
}
