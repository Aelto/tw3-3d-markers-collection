
/// Timer that runs at a fast interval
@addMethod(W3PlayerWitcher)
timer function TDMC_intervalFast(dt: float, id: int) {
  this.TDMC_cache.onIntervalFast();
}

/// Timer that runs at a medium interval
@addMethod(W3PlayerWitcher)
timer function TDMC_intervalMedium(dt: float, id: int) {
  this.TDMC_cache.onIntervalMedium();
}

/// Timer that runs at a medium interval
@addMethod(W3PlayerWitcher)
timer function TDMC_initialize(dt: float, id: int) {
  this.TDMC_cache.initialize();
}

@wrapMethod(W3PlayerWitcher)
function OnSpawned(spawnData : SEntitySpawnData) {
  wrappedMethod(spawnData);

  this.TDMC_cache = new TDMC_Cache in this;
  this.AddTimer('TDMC_initialize', 5.0, true);
  this.AddTimer('TDMC_intervalFast', 5.0, true);
  this.AddTimer('TDMC_intervalMedium', 15.0, true);
}
