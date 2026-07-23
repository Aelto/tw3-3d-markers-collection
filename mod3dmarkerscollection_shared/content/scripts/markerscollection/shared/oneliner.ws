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
