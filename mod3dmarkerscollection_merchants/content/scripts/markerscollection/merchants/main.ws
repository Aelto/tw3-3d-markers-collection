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

class TDMCME_Oneliner extends TDMC_OnelinerUnique {
  default tag = "TDMCME";

  function prepare(
    icon: string,
    visible_type: name,
    // out parameter to avoid copying the array
    out local_map_pins: array<SCommonMapPinInstance>
  ): TDMCME_Oneliner {
    this.visible_type = visible_type;
    this.text = "<img src='img://icons/markers/"+icon+"' height='32' width='32' />";
    this.offset = Vector(0, 0, 1.0);
    this.updateMapPinsCache(local_map_pins);

    return this;
  }

  private var visible_type: name;
  protected function shouldMapPinBeCached(out pin: SCommonMapPinInstance): bool {
    return pin.visibleType == this.visible_type;
  }
}
