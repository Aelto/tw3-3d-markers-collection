class TDMC_Oneliner extends SU_Oneliner {
  function init(position: Vector, text: string): TDMC_Oneliner {
    this.position = position;
    this.text = text;

    return this;
  }

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
}

class TDMC_OnelinerWithCache extends TDMC_Oneliner {
  protected var cached_map_pins: array<SCommonMapPinInstance>;

  public function updateMapPinsCache(
    // out parameter to avoid copying the array
    out local_map_pins: array<SCommonMapPinInstance>
  ) {
    var k: int;

    this.cached_map_pins.Clear();
    for (k = 0; k < local_map_pins.Size(); k += 1) {
      if (this.shouldMapPinBeCached(local_map_pins[k])) {
        this.cached_map_pins.PushBack(local_map_pins[k]);
      }
    }
  }

  protected function shouldMapPinBeCached(out pin: SCommonMapPinInstance): bool {
    return true;
  }
}

/// Sub-type of TDMC_Oneliner that is supposed to be unique based on a list of
/// map-pins it contains.
class TDMC_OnelinerUnique extends TDMC_OnelinerWithCache {
  /// Maximum distance for displayed map pins
  protected var maximum_distance: float;
  default maximum_distance = 150.0f;

  private var cached_distance_to_player: float;

  public function lookForCloserMapPin(player_position: Vector) {
    var k: int;

    this.computeSelfDistance(player_position);
    for (k = 0; k < this.cached_map_pins.Size(); k += 1) {
      this.setPositionIfCloser(player_position, this.cached_map_pins[k]);
    }
  }

  protected function computeSelfDistance(player_position: Vector) {
    this.cached_distance_to_player = VecDistanceSquared2D(
      player_position,
      this.position
    );

    if (
      this.maximum_distance > 0
      && cached_distance_to_player > this.maximum_distance * this.maximum_distance
    ) {
      this.unregister();
    }
  }

  protected function setPositionIfCloser(
    player_position: Vector,
    out other: SCommonMapPinInstance
  ) {
    var distance: float;

    distance = VecDistanceSquared2D(
      player_position,
      other.position
    );

    if (
      this.maximum_distance > 0
      && distance > this.maximum_distance * this.maximum_distance
    ) {
      return;
    }

    if (distance < this.cached_distance_to_player) {
      this.position = other.position;
      this.register();
    }
  }
}
