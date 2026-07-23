@addField(TDMC_Cache)
var fasttravel_oneliner: TDMCFT_Oneliner;

@wrapMethod(TDMC_Cache)
function initialize() {
  var local_map_pins: array<SCommonMapPinInstance>;
  wrappedMethod();

  local_map_pins = theGame
      .GetCommonMapManager()
      .GetMapPinInstances(theGame.GetWorld().GetPath());

  this.fasttravel_oneliner = (new TDMCFT_Oneliner in this)
    .prepare(local_map_pins);
}

@wrapMethod(TDMC_Cache)
function cacheLocalMapPins() {
  wrappedMethod();

  this.fasttravel_oneliner.updateMapPinsCache(this.local_map_pins);
}

@wrapMethod(TDMC_Cache)
function onIntervalFast() {
  wrappedMethod();

  this.fasttravel_oneliner.lookForCloserMapPin(thePlayer.GetWorldPosition());
}

class TDMCFT_Oneliner extends TDMC_OnelinerUnique {
  default tag = "TDMCFT";
  default maximum_distance = 250.0f;

  function prepare(
    out local_map_pins: array<SCommonMapPinInstance>
  ): TDMCFT_Oneliner {
    this.text = "<img src='img://icons/markers/icon_signpost.png' height='32' width='32' />";
    this.offset = Vector(0, 0, 1.0);

    this.updateMapPinsCache(local_map_pins);
    return this;
  }

  protected function shouldMapPinBeCached(out pin: SCommonMapPinInstance): bool {
    return pin.type == 'RoadSign' || pin.type == 'Harbor';
  }
}
