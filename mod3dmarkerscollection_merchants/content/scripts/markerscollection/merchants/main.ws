@addMethod(W3PlayerWitcher)
timer function TDMCME_delayOnelinerCreation(dt: float, id: int) {
  TDMCME_getShopkeeperPins();
}

@wrapMethod(W3PlayerWitcher)
function OnSpawned(spawnData : SEntitySpawnData) {
  wrappedMethod(spawnData);

  this.AddTimer('TDMCME_delayOnelinerCreation', 10.0f, false);
  this.AddTimer('TDMCME_delayOnelinerCreation', 20.0f, false);
  this.AddTimer('TDMCME_delayOnelinerCreation', 60.0f, true);
}

@wrapMethod(CR4Game)
function OnAfterLoadingScreenGameStart() {
  var result: bool;
  result = wrappedMethod();

  LogChannel('TDMCME', "OnAfterLoadingScreenGameStart");
  GetWitcherPlayer().AddTimer('TDMCME_delayOnelinerCreation', 5.0f);

  return result;
}

@addField(W3PlayerWitcher)
var TDMCME_oneliners: array<TDMCME_Oneliner>;

function TDMCME_getShopkeeperPins() {
  var local_map_pins: array<SCommonMapPinInstance>;
  var witcher: W3PlayerWitcher;
  var player_position: Vector;
  var icon: string;
  var k: int;

  SUOL_getManager().deleteByTagPrefix("TDMCME");

  witcher = GetWitcherPlayer();
  player_position = thePlayer.GetWorldPosition();

  local_map_pins = theGame
      .GetCommonMapManager()
      .GetMapPinInstances(theGame.GetWorld().GetPath());

  // builds a list of specialized oneliners that each look for a specific type
  // of map pin. Each oneliner caches a pre-filtered list of pins to make future
  // searches faster
  if (witcher.TDMCME_oneliners.Size() <= 0) {
    witcher.TDMCME_oneliners.PushBack(
      (new TDMCME_Oneliner in thePlayer)
        .prepare(
          "icon_purse.png",
          'Shopkeeper',
          local_map_pins
        )
    );

    witcher.TDMCME_oneliners.PushBack(
      (new TDMCME_Oneliner in thePlayer)
        .prepare(
          "icon_blacksmith.png",
          'Blacksmith',
          local_map_pins
        )
    );

    witcher.TDMCME_oneliners.PushBack(
      (new TDMCME_Oneliner in thePlayer)
        .prepare(
          "icon_armorer.png",
          'Armorer',
          local_map_pins
        )
    );

    witcher.TDMCME_oneliners.PushBack(
      (new TDMCME_Oneliner in thePlayer)
        .prepare(
          "icon_barber.png",
          'Hairdresser',
          local_map_pins
        )
    );

    witcher.TDMCME_oneliners.PushBack(
      (new TDMCME_Oneliner in thePlayer)
        .prepare(
          "icon_alchemy.png",
          'Alchemic',
          local_map_pins
        )
    );

    witcher.TDMCME_oneliners.PushBack(
      (new TDMCME_Oneliner in thePlayer)
        .prepare(
          "icon_herbalist.png",
          'Herbalist',
          local_map_pins
        )
    );

    witcher.TDMCME_oneliners.PushBack(
      (new TDMCME_Oneliner in thePlayer)
        .prepare(
          "icon_innkeeper.png",
          'Innkeeper',
          local_map_pins
        )
    );
  }

  for (k = 0; k < witcher.TDMCME_oneliners.Size(); k += 1) {
    witcher.TDMCME_oneliners[k].lookForCloserMapPin(player_position);
  }
}

class TDMCME_Oneliner extends SU_Oneliner {
  default tag = "TDMCME";

  //////////////////////////////////////////////////////////////////////////////
  // creation & caching logic:

  // caches the positions of the map pins that match this oneliner's type.
  // Only the position is cached to avoid wasting memory.
  private var pins: array<Vector>;
  function prepare(
    icon: string,
    visible_type: name,
    // out parameter to avoid copying the array
    out local_map_pins: array<SCommonMapPinInstance>
  ): TDMCME_Oneliner {
    var k: int;

    this.text = "<img src='img://icons/markers/"+icon+"' height='32' width='32' />";
    this.pins.Clear();
    for (k = 0; k < local_map_pins.Size(); k += 1) {
      if (local_map_pins[k].visibleType == visible_type) {
        this.pins.PushBack(local_map_pins[k].position);
      }
    }

    // set a default position so that it doesn't point to 0;0;0
    if (this.pins.Size() > 0) {
      this.position = local_map_pins[0].position;
    }

    return this;
  }

  private var is_registered: bool;
  function init(position: Vector): TDMCME_Oneliner {
    this.position = position + Vector(0, 0, 1.0);

    if (!this.is_registered) {
      this.register();
      this.is_registered = true;
    }

    return this;
  }

  //////////////////////////////////////////////////////////////////////////////
  // rendering logic:

  private var was_visible_by_senses: bool;
  function getVisible(player_position: Vector): bool {
    if (theGame.IsFocusModeActive()) {
      this.was_visible_by_senses = true;
      this.setOpacity(1);

      return true;
    }

    // the opacity is lowered as the OL drifts away from the center of the screen
    this.setOpacity(1 - AbsF(0.5 - this.cached_screen_position.X) * 3);
    this.was_visible_by_senses = this.opacity > 0;

    return this.was_visible_by_senses;
  }

  //////////////////////////////////////////////////////////////////////////////
  // position & updating logic:

  public function lookForCloserMapPin(player_position: Vector) {
    var k: int;

    this.computeSelfDistance(player_position);
    for (k = 0; k < this.pins.Size(); k += 1) {
      this.setPositionIfCloser(player_position, this.pins[k]);
    }
  }

  private var cached_distance_to_player: float;
  function computeSelfDistance(player_position: Vector) {
    this.cached_distance_to_player = VecDistanceSquared2D(
      player_position,
      this.position
    );
  }

  function setPositionIfCloser(player_position: Vector, other_position: Vector) {
    var distance: float;

    distance = VecDistanceSquared2D(
      player_position,
      other_position
    );

    if (distance < this.cached_distance_to_player) {
      this.init(other_position);
    }
  }
}
