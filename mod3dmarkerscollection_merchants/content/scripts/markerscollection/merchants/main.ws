@addField(TDMC_Cache)
var merchants_oneliners: array<TDMCME_Oneliner>;

@wrapMethod(TDMC_Cache)
function initialize() {
  var local_map_pins: array<SCommonMapPinInstance>;
  wrappedMethod();

  local_map_pins = theGame
      .GetCommonMapManager()
      .GetMapPinInstances(theGame.GetWorld().GetPath());

  // builds a list of specialized oneliners that each look for a specific type
  // of map pin. Each oneliner caches a pre-filtered list of pins to make future
  // searches faster
  this.merchants_oneliners.Clear();
  this.merchants_oneliners.PushBack(
    (new TDMCME_Oneliner in thePlayer)
      .prepare(
        "icon_purse.png",
        'Shopkeeper',
        local_map_pins
      )
  );

  this.merchants_oneliners.PushBack(
    (new TDMCME_Oneliner in thePlayer)
      .prepare(
        "icon_blacksmith.png",
        'Blacksmith',
        local_map_pins
      )
  );

  this.merchants_oneliners.PushBack(
    (new TDMCME_Oneliner in thePlayer)
      .prepare(
        "icon_armorer.png",
        'Armorer',
        local_map_pins
      )
  );

  this.merchants_oneliners.PushBack(
    (new TDMCME_Oneliner in thePlayer)
      .prepare(
        "icon_barber.png",
        'Hairdresser',
        local_map_pins
      )
  );

  this.merchants_oneliners.PushBack(
    (new TDMCME_Oneliner in thePlayer)
      .prepare(
        "icon_alchemy.png",
        'Alchemic',
        local_map_pins
      )
  );

  this.merchants_oneliners.PushBack(
    (new TDMCME_Oneliner in thePlayer)
      .prepare(
        "icon_herbalist.png",
        'Herbalist',
        local_map_pins
      )
  );

  this.merchants_oneliners.PushBack(
    (new TDMCME_Oneliner in thePlayer)
      .prepare(
        "icon_innkeeper.png",
        'Innkeeper',
        local_map_pins
      )
  );
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

class TDMCME_Oneliner extends SU_Oneliner {
  default tag = "TDMCME";

  //////////////////////////////////////////////////////////////////////////////
  // creation & caching logic:

  // caches the positions of the map pins that match this oneliner's type.
  // Only the position is cached to avoid wasting memory.
  private var pins: array<Vector>;
  private var visible_type: name;
  function prepare(
    icon: string,
    visible_type: name,
    // out parameter to avoid copying the array
    out local_map_pins: array<SCommonMapPinInstance>
  ): TDMCME_Oneliner {
    this.visible_type = visible_type;
    this.text = "<img src='img://icons/markers/"+icon+"' height='32' width='32' />";
    this.updateMapPinsCache(local_map_pins);

    // set a default position so that it doesn't point to 0;0;0
    if (this.pins.Size() > 0) {
      this.position = local_map_pins[0].position;
    }

    return this;
  }

  public function updateMapPinsCache(
    // out parameter to avoid copying the array
    out local_map_pins: array<SCommonMapPinInstance>
  ) {
    var k: int;

    this.pins.Clear();
    for (k = 0; k < local_map_pins.Size(); k += 1) {
      if (local_map_pins[k].visibleType == this.visible_type) {
        this.pins.PushBack(local_map_pins[k].position);
      }
    }
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

    if (cached_distance_to_player > 150 * 150) {
      this.unregister();
      this.is_registered = false;
    }
  }

  function setPositionIfCloser(player_position: Vector, other_position: Vector) {
    var distance: float;

    distance = VecDistanceSquared2D(
      player_position,
      other_position
    );

    if (distance > 150 * 150) {
      return;
    }

    if (distance < this.cached_distance_to_player) {
      this.init(other_position);
    }
  }
}
