@addField(TDMC_Cache)
var activequest_oneliner: TDMCAQ_Oneliner;

@wrapMethod(TDMC_Cache)
function initialize() {
  var local_map_pins: array<SCommonMapPinInstance>;
  wrappedMethod();

  local_map_pins = theGame
      .GetCommonMapManager()
      .GetMapPinInstances(theGame.GetWorld().GetPath());

  this.activequest_oneliner = (new TDMCAQ_Oneliner in this)
    .prepare(local_map_pins);
}

@wrapMethod(TDMC_Cache)
function cacheLocalMapPins() {
  wrappedMethod();
  this.activequest_oneliner.updateMapPinsCache(this.local_map_pins);
}

@wrapMethod(TDMC_Cache)
function onIntervalFast() {
  wrappedMethod();
  this.activequest_oneliner.updateToCurrentlyTrackedQuest();
}


@wrapMethod(CR4HudModuleQuests)
function UpdateObjectives() {
  wrappedMethod();

  TDMC_CacheGet()
    .activequest_oneliner
    .updateToCurrentlyTrackedQuest();
}

@wrapMethod(CR4HudModuleQuests)
function HighlightObjective(objective: CJournalQuestObjective) {
  wrappedMethod(objective);

  TDMC_CacheGet()
    .activequest_oneliner
    .updateToCurrentlyTrackedQuest();
}

class TDMCAQ_Oneliner extends TDMC_OnelinerWithCache {
  default tag = "TDMCAQ";

  function prepare(
    out local_map_pins: array<SCommonMapPinInstance>
  ): TDMCAQ_Oneliner {
    this.updateMapPinsCache(local_map_pins);

    return this;
  }

  protected function shouldMapPinBeCached(out pin: SCommonMapPinInstance): bool {
    return theGame.GetCommonMapManager().IsQuestPinType(pin.type);
  }

  public function updateToCurrentlyTrackedQuest() {
    var tracked_quest: CJournalQuest;
    var k: int;

    tracked_quest = theGame.GetJournalManager()
      .GetTrackedQuest();

    for (k = 0; k < this.cached_map_pins.Size(); k += 1) {
      if (!this.cached_map_pins[k].isHighlighted) {
        return;
      }

      this.setPositionIfTracked(tracked_quest, this.cached_map_pins[k]);
    }

    // then update the pin's text to match the currently tracked quest:
    this.text = "<img src='img://icons/inventory/other/squarecoin.dds' height='18' width='18' /><br/>"
      + "<font size='16'>"
      + GetLocStringById(tracked_quest.GetTitleStringId())
      + "</font>";
    this.update();
  }

  private function setPositionIfTracked(
    tracked_quest: CJournalQuest,
    out pin: SCommonMapPinInstance
  ) {
    var objective: CJournalQuestObjective;
    var objective_quest: CJournalQuest;

    objective = (CJournalQuestObjective)theGame
      .GetJournalManager()
      .GetEntryByGuid(pin.guid);

    if (objective) {
      objective_quest = objective.GetParentQuest();

      if (tracked_quest.guid == objective_quest.guid) {
        this.position = pin.position;
        this.register();
      }
    }
  }
}
