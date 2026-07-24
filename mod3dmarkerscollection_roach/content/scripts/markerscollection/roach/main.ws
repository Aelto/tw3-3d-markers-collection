@addField(TDMC_Cache)
var roach_oneliner: TDMCRO;


@wrapMethod(TDMC_Cache)
function initialize() {
  wrappedMethod();

  this.roach_oneliner = (new TDMCRO in this).prepare();
}

@wrapMethod(W3HorseManager)
function ApplyHorseUpdateOnSpawn(): bool {
  var result: bool;
  var cache: TDMC_Cache;
  result = wrappedMethod();

  cache = TDMC_CacheGet();
  cache.roach_oneliner.roach = thePlayer.GetHorseWithInventory();
  cache.roach_oneliner.register();

  return result;
}

@wrapMethod(TDMC_Cache)
function onIntervalFast() {
  var cache: TDMC_Cache;
  var horse: CNewNPC;
  wrappedMethod();

  cache = TDMC_CacheGet();
  if (cache.roach_oneliner.roach) {
    cache.roach_oneliner.register();
  }
  else {
    horse = thePlayer.GetHorseWithInventory();
    if (horse) {
      cache.roach_oneliner.roach = thePlayer.GetHorseWithInventory();
      cache.roach_oneliner.register();
    }
    else {
      cache.roach_oneliner.unregister();
    }
  }
}

class TDMCRO extends TDMC_Oneliner {
  default tag = "TDMCUP";

  public var roach: CNewNPC;

  function prepare(): TDMCRO {
    this.text = "<img src='img://icons/markers/icon_horse.png' height='32' width='32' />";
    this.offset = Vector(0, 0, 2.5);

    return this;
  }

  function getPosition(): Vector {
    if (this.roach) {
      this.position = this.roach.GetWorldPosition() + this.offset;
    }

    return this.position;
  }

  function getVisible(player_position: Vector): bool {
    return VecDistanceSquared(this.position, player_position) > 5 * 5
        && super.getVisible(player_position);
  }
}
