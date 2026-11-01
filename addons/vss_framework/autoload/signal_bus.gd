extends Node
## Global event bus.
##
## Systems communicate through these signals instead of holding hard references to
## each other. This keeps the framework loosely coupled and easy to extend.

# -- Run lifecycle -----------------------------------------------------------

## Emitted when a run starts.
signal run_started

## Emitted when the player reaches the end of the stage timer (victory).
signal game_won

## Emitted when the player runs out of health (defeat).
signal game_over

# -- Player ------------------------------------------------------------------

## Emitted whenever the player's health changes.
signal player_hp_changed(current_hp: float, max_hp: float)

## Emitted when the player's health reaches zero (defeat).
signal player_died

## Emitted when the player gains a level.
signal player_leveled_up(new_level: int)

## Emitted when the player's experience changes.
signal xp_changed(current_xp: float, xp_to_next: float)

## Emitted when level-up choices are ready to be shown.
signal level_up_choices_ready(choices: Array)

## Emitted when the player picks a level-up choice.
signal level_up_choice_picked(choice: UpgradeChoice)

# -- Enemies -----------------------------------------------------------------

## Emitted when an enemy dies. [param xp_value] is the experience it drops.
signal enemy_died(enemy: Enemy, xp_value: float)

# -- Pickups -----------------------------------------------------------------

## Emitted when a pickup (e.g. an experience gem) is collected.
signal pickup_collected(pickup: Pickup)
