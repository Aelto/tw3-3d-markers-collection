//! Possible performance improvements:
//! - Re-using the same instance of the OL class instead of destroying & creating
//    new ones each time.

@wrapMethod(CR4HudModuleQuests)
function UpdateObjectives() {
  wrappedMethod();
  TDMCAQ_tryCreateOneliner();
}

@wrapMethod(CR4HudModuleQuests)
function HighlightObjective(objective: CJournalQuestObjective) {
  wrappedMethod(objective);
  TDMCAQ_tryCreateOneliner();
}

@wrapMethod(W3PlayerWitcher)
function OnSpawned( spawnData : SEntitySpawnData ) {
  wrappedMethod(spawnData);

  this.AddTimer('TDMCAQ_delayOnelinerCreation', 1.0f);
  this.AddTimer('TDMCAQ_delayOnelinerCreation', 5.0f);
  this.AddTimer('TDMCAQ_delayOnelinerCreation', 10.0f);
}

@addMethod(W3PlayerWitcher)
timer function TDMCAQ_delayOnelinerCreation(dt: float, id: int) {
  TDMCAQ_tryCreateOneliner();
}

class TDMCAQ_Oneliner extends SU_Oneliner {
  default tag = "TDMCAQ";

  function prepare(
    text: string,
    position: Vector
  ): TDMCAQ_Oneliner {
    super.init(position, text);
    this.register();

    return this;
  }

  private var was_visible_by_senses: bool;
  function getVisible(player_position: Vector): bool {
    if (
      theGame.IsFocusModeActive()
      || VecDistanceSquared2D(player_position, this.position) < 20 * 20
    ) {
      this.was_visible_by_senses = true;
      this.setOpacity(1);

      return true;
    }

    return this.was_visible_by_senses;
  }
}

function TDMCAQ_tryCreateOneliner() {
  var local_map_pins: array<SCommonMapPinInstance>;
  var k: int;

  var objective: CJournalQuestObjective;
  var objective_quest: CJournalQuest;
  var tracked_quest: CJournalQuest;

  var player: CR4Player = thePlayer;

  tracked_quest = theGame.GetJournalManager()
    .GetTrackedQuest();

  // remove all oneliners from TDMCAQ.
  SUOL_getManager().deleteByTagPrefix("TDMCAQ");

  local_map_pins = theGame
      .GetCommonMapManager()
      .GetMapPinInstances(theGame.GetWorld().GetPath());

  for (k = 0; k < local_map_pins.Size(); k += 1) {
    if (!theGame.GetCommonMapManager().IsQuestPinType(local_map_pins[k].type)) {
      continue;
    }

    objective = (CJournalQuestObjective)theGame
      .GetJournalManager()
      .GetEntryByGuid(local_map_pins[k].guid);

    if (objective) {
      objective_quest = objective.GetParentQuest();

      if (tracked_quest.guid != objective_quest.guid) {
        continue;
      }

      if (!local_map_pins[k].isHighlighted) {
        continue;
      }

      (new TDMCAQ_Oneliner in thePlayer)
        .init(
          "<img src='img://icons/inventory/other/squarecoin.dds' height='18' width='18' /><br/>"
          + "<font size='16'>"
          + GetLocStringById(objective_quest.GetTitleStringId())
          + "</font>",
          local_map_pins[k].position
        );
    }
  }
}
