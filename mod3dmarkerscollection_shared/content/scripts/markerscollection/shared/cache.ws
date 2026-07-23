@addField(W3PlayerWitcher)
var TDMC_cache: TDMC_Cache;

class TDMC_Cache {
  //////////////////////////////////////////////////////////////////////////////
  // set of methods that are meant to be @wrapMethod by the other modules,
  // they offer common patterns & timers to reduce code duplication and improve
  // performances thanks to caching.

  public function initialize() {}
  public function onIntervalFast() {}
  public function onIntervalMedium() {
    this.cacheLocalMapPins();
  }

  //////////////////////////////////////////////////////////////////////////////
  // caching methods, they can be @wrapMethod to be extend and offer more precise
  // caching if needed.

  private var local_map_pins: array<SCommonMapPinInstance>;
  public function cacheLocalMapPins() {
    this.local_map_pins = theGame
        .GetCommonMapManager()
        .GetMapPinInstances(theGame.GetWorld().GetPath());
  }
}
