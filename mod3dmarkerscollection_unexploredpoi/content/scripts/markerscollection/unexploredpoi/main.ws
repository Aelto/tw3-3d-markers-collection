@addMethod(W3PlayerWitcher)
timer function TDMCUP_delayOnelinerCreation(dt: float, id: int) {
  var pins: array<SCommonMapPinInstance>;
  var k: int;

  pins = TDMCUP_getPinsByCardinalDirection();
  SUOL_getManager().deleteByTagPrefix("TDMCUP");

  for (k = 0; k < pins.Size(); k += 1) {
    (new TDMCUP_Oneliner in thePlayer).init(pins[k].position);
  }
}

@wrapMethod(W3PlayerWitcher)
function OnSpawned(spawnData : SEntitySpawnData) {
  wrappedMethod(spawnData);

  this.AddTimer('TDMCUP_delayOnelinerCreation', 10.0f, false);
  this.AddTimer('TDMCUP_delayOnelinerCreation', 20.0f, false);
  this.AddTimer('TDMCUP_delayOnelinerCreation', 60.0f, true);
}

@wrapMethod(CCommonMapManager)
function SetEntityMapPinDiscoveredScript(
  isFastTravelPoint: bool,
  tag: name,
  optional set: bool
) {
  wrappedMethod(isFastTravelPoint, tag, set);

  GetWitcherPlayer().AddTimer('TDMCUP_delayOnelinerCreation', 5.0f);
}


function TDMCUP_getPinsByCardinalDirection(): array<SCommonMapPinInstance> {
  var local_map_pins: array<SCommonMapPinInstance>;
  var player_position: Vector;
  var distance: float;
  var k, j: int;

  var picked_pins_by_cardinal: array<SCommonMapPinInstance>;
  var direction: Vector;
  var angle: float;
  var cardinal_index: int;

  var pins_by_cardinal: array<array<SCommonMapPinInstance>>;
  var picked_pin_distance: float;
  var picked_pin: SCommonMapPinInstance;

  LogChannel('TDMCUP', "getPinsByCardinalDirection()");

  local_map_pins = theGame
      .GetCommonMapManager()
      .GetMapPinInstances(theGame.GetWorld().GetPath());

  player_position = thePlayer.GetWorldPosition();

  pins_by_cardinal.Grow(4);

  // 1) filter & organize the pins by cardinal direction compared to the player
  for (k = 0; k < local_map_pins.Size(); k += 1) {
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

    direction = player_position - local_map_pins[k].position;
    angle = AngleNormalize(VecHeading(direction));

    // by diving the [0;360] range by 90, we get values in the [0;4[ range which
    // can be used as an index in an array
    cardinal_index = FloorF(angle / 90.0);

    // LogChannel('TDMCUP', "add pin to cardinal " + cardinal_index);
    pins_by_cardinal[cardinal_index].PushBack(local_map_pins[k]);
  }

  // 2) for each cardinal direction, pick the closest pin then group them in a
  // single final array
  for (k = 0; k < pins_by_cardinal.Size(); k += 1) {
    picked_pin_distance = -1;

    for (j = 0; j < pins_by_cardinal[k].Size(); j += 1) {
      distance = VecDistanceSquared2D(player_position, pins_by_cardinal[k][j].position);

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

class TDMCUP_Oneliner extends SU_Oneliner {
  default tag = "TDMCUP";

  function init(position: Vector): TDMCUP_Oneliner {
    this.position = position + Vector(0, 0, 1.0);

    // dlc\dlcmarkerscollection_icons\data\gameplay\gui_new\icons\markers\icon_signpost.png
    this.text = "<img src='img://icons/markers/icon_point_of_interest.png' height='32' width='32' />";
    this.register();

    return this;
  }

  private var was_visible_by_senses: bool;
  function getVisible(player_position: Vector): bool {
    if (
      theGame.IsFocusModeActive()
      && super.getVisible(player_position)
    ) {
      this.was_visible_by_senses = true;

      return true;
    }

    this.was_visible_by_senses = this.cached_screen_position.X >= 0.33
      && this.cached_screen_position.X <= 0.66;

    return this.was_visible_by_senses;
  }
}
