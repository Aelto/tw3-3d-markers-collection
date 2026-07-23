@addField(W3PlayerWitcher)
var TDMC_cache: TDMC_Cache;

class TDMC_Cache {
  public function initialize() {}

  public function onIntervalFast() {}
  public function onIntervalMedium() {
    this.cacheLocalMapPins();
  }

  private var local_map_pins: array<SCommonMapPinInstance>;
  public function cacheLocalMapPins() {
    this.local_map_pins = theGame
        .GetCommonMapManager()
        .GetMapPinInstances(theGame.GetWorld().GetPath());
  }
}
