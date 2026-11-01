# VSS Framework — Usage Guide

This guide is the deep companion to the [README.md](README.md). The README gives
you the quick overview; this document explains **how the framework works**, what
connects to what, and how to add your own content. Read it top to bottom once,
then use the "How to add…" section as a recipe book.

- [Overview](#overview)
- [Before & after](#before--after)
- [The big picture](#the-big-picture)
- [Boot sequence](#boot-sequence)
- [The three autoloads](#the-three-autoloads)
- [The data layer](#the-data-layer)
- [The object layer](#the-object-layer)
- [Systems](#systems)
- [UI](#ui)
- [Content registration](#content-registration)
- [How to add…](#how-to-add)
- [Signals reference](#signals-reference)
- [Extension points](#extension-points)
- [Conventions & gotchas](#conventions--gotchas)

---

## Overview

VSS Framework is a reusable **Godot 4 / GDScript 2.0** architecture for
horde-survival ("bullet-heaven") games. It provides the genre's core loop out of
the box:

- a data-driven **player character** with auto-firing weapons and passive
  accessories,
- **hordes of enemies** that chase and damage you,
- **experience gems** dropped on death,
- a **level-up screen** that pauses the game and offers three random upgrades,
- a **timed stage** with a spawn director that ramps difficulty.

Everything that varies between characters, weapons, accessories, enemies and
stages is **data**, not code. You extend the framework by registering data
(definitions) and, when you need custom behaviour, by subclassing one small hook.

Requirements: **Godot 4.3 or newer**.

VSS Framework ships as a **Godot addon**. Enable it from **Project → Project
Settings → Plugins** to register its autoloads and classes, then build your own
content on top of it.

---

## Before & after

The framework's whole point is to replace boilerplate with data. Here is the same
feature written **without** the framework, then **with** it.

### An auto-firing weapon

**Before** — two scripts and ~30 lines of boilerplate just to fire one projectile
at the nearest enemy, with no stat scaling, piercing, or level-up support:

```gdscript
# player.gd — raw Godot
extends CharacterBody2D

var cooldown := 1.2
var damage := 8.0
var timer := 0.0
var projectile_scene := preload("res://projectile.tscn")

func _physics_process(delta: float) -> void:
    timer -= delta
    if timer <= 0.0:
        timer = cooldown
        fire()

func fire() -> void:
    var enemies := get_tree().get_nodes_in_group("enemies")
    if enemies.is_empty():
        return
    var origin := global_position
    enemies.sort_custom(func(a, b):
        return origin.distance_squared_to(a.global_position) < origin.distance_squared_to(b.global_position))
    var proj := projectile_scene.instantiate()
    proj.damage = damage
    proj.direction = (enemies[0].global_position - origin).normalized()
    proj.global_position = origin
    get_tree().current_scene.add_child(proj)
```

```gdscript
# projectile.gd — raw Godot
extends Area2D

var damage: float
var direction: Vector2
var speed := 400.0
var lifetime := 2.0

func _physics_process(delta: float) -> void:
    global_position += direction * speed * delta
    lifetime -= delta
    if lifetime <= 0.0:
        queue_free()
```

**After** — a four-line subclass plus a data registration. Targeting, cooldown,
spawning, pierce, stat scaling and level-up integration are all handled for you:

```gdscript
# content/weapons/wand.gd — with the framework
class_name Wand
extends Weapon
## The base Weapon handles cooldown, targeting, spawning and scaling.
```

```gdscript
var wand := WeaponData.new()
wand.id = "wand"
wand.base_stats = _stats({"power": 8.0, "cooldown": 1.2, "speed": 400.0, "duration": 2.0})
wand.weapon_script = preload("res://content/weapons/wand.gd")
DataManager.register_weapon(wand)
```

### A chasing enemy

**Before** — chasing, contact damage, and the XP drop are all hand-rolled:

```gdscript
# enemy.gd — raw Godot
extends CharacterBody2D

var hp := 10.0
var move_speed := 90.0
var contact_damage := 5.0
var xp_value := 1.0
var attack_timer := 0.0

func _physics_process(delta: float) -> void:
    var player := get_tree().get_first_node_in_group("player")
    if player == null:
        return
    velocity = (player.global_position - global_position).normalized() * move_speed
    move_and_slide()
    attack_timer -= delta
    if attack_timer <= 0.0 and global_position.distance_to(player.global_position) < 20.0:
        attack_timer = 0.5
        player.take_damage(contact_damage)

func take_damage(amount: float) -> void:
    hp -= amount
    if hp <= 0.0:
        var gem := preload("res://gem.tscn").instantiate()
        gem.value = xp_value
        gem.global_position = global_position
        get_tree().current_scene.add_child(gem)
        queue_free()
```

**After** — override only the visuals; movement, contact damage, and the XP drop
come from `Enemy`:

```gdscript
# content/enemies/chaser.gd — with the framework
class_name Chaser
extends Enemy

func _draw() -> void:
    draw_circle(Vector2.ZERO, 12.0, Color(0.9, 0.4, 0.2))
```

```gdscript
var chaser := EnemyData.new()
chaser.id = "chaser"
chaser.max_hp = 10.0
chaser.move_speed = 90.0
chaser.contact_damage = 5.0
chaser.xp_value = 1.0
chaser.enemy_script = preload("res://content/enemies/chaser.gd")
DataManager.register_enemy(chaser)
```

Same story for accessories, characters and stages — a data definition plus, at
most, one small override.

---

## The big picture

The framework is an addon: its code lives under `addons/vss_framework/`, split
into six layers. Your own game content lives outside the addon, in your project's
own folders.

```
addons/vss_framework/
├── demo/        entry scene — registers content, builds the world, starts a run
├── autoload/    singletons — SignalBus, DataManager, GameManager
├── data/        Resource classes that *describe* a thing (weapon, enemy, …)
├── objects/     runtime gameplay nodes/objects (player, enemy, projectile, …)
├── systems/     recurring logic — spawn pacing and level-up choice generation
├── ui/          HUD and the level-up screen (both built in code)
└── content/     example content — replace with your own game's content
```

**Data flows one way.** Content is registered into `DataManager` as `Resource`
instances. Runtime objects look data up by string id and are constructed from the
script a data entry points at. Systems never reach into each other; they talk
through `SignalBus` signals. `GameManager` owns the high-level run state.

A single frame looks like this:

```
GameManager._process        → advance timer, check win
CharacterController._physics_process → input, move, regen, drive weapons/accessories
SpawnDirector._process      → spawn an enemy when the timer expires
Enemy._physics_process      → chase player, deal contact damage
Projectile._physics_process → move, hit enemies
Pickup._physics_process     → magnet toward player, grant XP on contact
```

---

## Boot sequence

When you press F5, Godot loads `addons/vss_framework/demo/main.tscn`, a bare `Node2D` with
[main.gd](addons/vss_framework/demo/main.gd) attached. Its `_ready()` runs three steps in order:

1. **Register content** — `ExampleContent.register_all()` creates and registers
   the demo character, weapons, accessory, enemies and stage into `DataManager`
   (see [Content registration](#content-registration)).
2. **Build the world** — `_setup_world()` adds four children to the main node:
   - a `SpawnDirector` (given the `"grasslands"` stage),
   - a `LevelUpSystem`,
   - a `HUD`,
   - a `LevelUpScreen` (given a reference to the level-up system).
3. **Start the run** — `_start_run()` creates a `CharacterController`, assigns it
   the `"demo"` `CharacterData`, adds it to the tree (its `_ready` builds its
   collision body and applies its data), attaches a `Camera2D`, then calls
   `GameManager.start_run(character, stage)`.

`start_run()` sets `player`, `stage_data`, resets `elapsed`, sets
`is_running = true`, and emits `SignalBus.run_started`.

> **Your entry point:** to ship your own game, write your own content registration
> (a copy of `ExampleContent`, or `.tres` resources), register your own character
> and stage, and build your own main scene. The demo in
> `addons/vss_framework/demo/` is the reference for how it all fits together.

---

## The three autoloads

The three singletons are registered by the plugin's
[plugin.gd](addons/vss_framework/plugin.gd) when you enable the addon. They are
created before the main scene loads, so any script can refer to them by name
(`SignalBus`, `DataManager`, `GameManager`).

### `SignalBus`

The event bus. Systems subscribe to signals here instead of holding references to
each other. See the full [signals reference](#signals-reference) for who emits
and who listens to each one.

### `DataManager`

The central registry. It holds five `Dictionary`s keyed by string id:

| Dictionary | Register | Look up |
|---|---|---|
| `characters` | `register_character(data)` | `get_character(id)` |
| `weapons` | `register_weapon(data)` | `get_weapon(id)` |
| `accessories` | `register_accessory(data)` | `get_accessory(id)` |
| `enemies` | `register_enemy(data)` | `get_enemy(id)` |
| `stages` | `register_stage(data)` | `get_stage(id)` |

Two helpers — `weapon_ids()` and `accessory_ids()` — return every registered id,
and are used by the level-up system to offer "new item" choices.

### `GameManager`

Owns a run's high-level state and the win/lose transitions:

| Member | Meaning |
|---|---|
| `player: CharacterController` | The active player, or `null`. |
| `stage_data: StageData` | The current stage definition. |
| `elapsed: float` | Seconds since `start_run`. |
| `is_running: bool` | `true` while a run is being played. |
| `world_rect: Rect2` | World bounds; clamps the player and constrains spawns. |

Key methods:

- `start_run(player, stage)` — begin a run.
- `pause()` / `unpause()` — toggle `get_tree().paused`.
- `spawn(node)` — add a node to `get_tree().current_scene` (used to spawn
  projectiles, pickups and enemies without a hard reference to the world).
- `_win()` / `_lose()` — emit the corresponding signal and stop the clock. These
  are called automatically by the timer and by `SignalBus.player_died`.

---

## The data layer

Every "thing" is a `Resource` subclass in [data/](addons/vss_framework/data/). You register an instance
by id; gameplay code reads it back and constructs the matching runtime object.

### `ModifierStats`

The shared stat bag. Every field is an exported float (or int) so values are
visible and editable in the inspector. It has three helpers:

- `reset()` — zero everything.
- `add(other)` — add another bag onto this one (returns `self`).
- `scaled(factor)` — return a new bag with every value multiplied.

The full field list lives in [modifier_stats.gd](addons/vss_framework/data/modifier_stats.gd). The ones
the base gameplay actually uses today:

| Stat | Meaning | Used by |
|---|---|---|
| `power` | +% weapon damage | weapons scale damage |
| `area` | +% weapon area | weapons scale hit radius |
| `speed` | +% projectile speed | weapons scale speed |
| `duration` | +% projectile lifetime | weapons scale duration |
| `cooldown` | −% weapon cooldown | weapons scale cooldown |
| `amount` | + projectiles per shot | weapons add to amount |
| `move_speed` | px/s movement | character movement |
| `max_hp` | maximum health | character health |
| `magnet` | + pickup radius (px) | pickup magnet |
| `growth` | +% XP gained | xp gain |
| `armor` | flat damage reduction per hit | damage taken |
| `regen` | health per second | character regen |

The remaining fields (`luck`, `greed`, `shields`, `revivals`, `rerolls`, `skips`,
`curse`, `banish`, `shroud`, `charm`, `defang`, `thorns`, `invul_time_bonus`,
`fever`, `recycle`) are **reserved placeholders** for you to wire up — see
[Extension points](#extension-points).

### `CharacterData`

Describes a playable character: `id`, `display_name`, `description`,
`base_stats` (a `ModifierStats`), and `starting_weapons` (an array of weapon ids).

### `WeaponData`

Describes a weapon: `id`, `display_name`, `description`, `max_level`,
`base_stats` (level-1 stats), `level_bonus` (added per extra level), `pierce`
(projectiles this weapon's projectiles pass through), `weapon_script` (the
`Weapon` subclass), `projectile_scene` (ignored by area weapons), and
`is_area_weapon`.

### `AccessoryData`

Describes a passive accessory: `id`, `display_name`, `description`, `max_level`,
`stats`, `level_bonus`, and `accessory_script` (the `Accessory` subclass).

### `EnemyData`

Describes an enemy: `id`, `display_name`, `max_hp`, `move_speed`,
`contact_damage`, `xp_value`, `scale`, and `enemy_script` (the `Enemy` subclass).

### `StageData`

Describes a timed survival stage: `id`, `display_name`, `duration_seconds`,
`enemy_pool` (array of enemy ids), `spawn_interval`, `spawn_ramp` (interval shrink
per minute), and `max_enemies`.

### `UpgradeChoice`

A single option on the level-up screen. Its `kind` enum is one of `NEW_WEAPON`,
`UPGRADE_WEAPON`, `NEW_ACCESSORY`, `UPGRADE_ACCESSORY`, or `STAT_BOOST`. It carries
an `item_id` (for weapon/accessory choices) or a `stat_name` + `stat_value` (for
stat boosts), plus `display_name` and `description` for the card.

---

## The object layer

Runtime gameplay objects live in [objects/](addons/vss_framework/objects/).

### Equipment hierarchy

```
Equipment (RefCounted)   — not a Node; owned and driven by the character
├── Weapon               — auto-fires on a cooldown
└── Accessory            — passive; grants stats to its owner
```

`Equipment` holds `owner` and `level`, and defines `is_max_level()`, `level_up()`,
`update(delta)`, and `display_name()`. Because it is a `RefCounted` (not a
`Node`), its lifetime is owned by the `CharacterController` that holds it in a
list and calls `update()` every frame.

### `CharacterController` (`CharacterBody2D`)

The player. Owns `weapons` and `accessories` arrays, plus three stat layers:

- `base_stats` — from `CharacterData`.
- `level_bonus` — accumulates flat stat-boost choices.
- `stats` — the cached **effective** result.

`recalculate_stats()` recomputes:

```
stats = base_stats + level_bonus + Σ accessory.get_current_stats()
```

then reads `max_hp`, `move_speed` and `magnet_radius` off the result, and keeps
`hp` clamped (healing by any `max_hp` increase). Every frame `_physics_process`
moves the player, applies regen, and calls `update(delta)` on each weapon and
accessory.

Key methods you'll call from content or systems:

- `add_weapon(data)` / `add_accessory(data)` — construct and attach equipment.
- `find_weapon(id)` / `find_accessory(id)` — look up owned equipment by id.
- `take_damage(amount)` — apply damage (respects `armor`, emits `player_hp_changed`,
  triggers death).
- `gain_xp(amount)` — add XP (respects `growth`) and check for a level-up.

### `Weapon`

Auto-fires on a cooldown. `update()` counts down the cooldown and calls `fire()`,
which delegates to `_fire()` — the hook subclasses override. The default `_fire()`
launches projectiles at the nearest enemies via `_fire_projectiles()`, which asks
`_enemies_by_distance()` for targets sorted by distance.

Stat accessors scale the weapon's own per-level numbers by the **owner's**
effective stats:

| Accessor | Formula |
|---|---|
| `get_damage()` | `power × (1 + owner.power)` |
| `get_cooldown()` | `max(0.05, cooldown × (1 − owner.cooldown))` |
| `get_area()` | `area × (1 + owner.area)` |
| `get_speed()` | `speed × (1 + owner.speed)` |
| `get_duration()` | `duration × (1 + owner.duration)` |
| `get_amount()` | `max(1, amount + owner.amount)` |
| `get_pierce()` | `weapon_data.pierce` |

The weapon's own per-level numbers come from `_level_stats()`:
`base_stats + level_bonus × (level − 1)`.

### `Accessory`

Passive. `get_current_stats()` returns `stats + level_bonus × (level − 1)`, which
the owner folds into `recalculate_stats()`.

### `Enemy` (`CharacterBody2D`)

Chases the player, deals contact damage on a 0.5s cooldown via a child `Area2D`,
and drops a `Pickup` gem on death. `take_damage()` is guarded so a single enemy
dies (and drops) exactly once even if multiple projectiles hit it in one frame.

### `Projectile` (`Area2D`)

Moves in a straight line, damages the first enemies it touches, and expires after
`pierce` hits or `lifetime` seconds.

### `Pickup` (`Area2D`)

A collectible (XP gem). Sits still until the player is within
`60 + player.stats.magnet` px, then flies toward them and grants XP on contact.

### Collision layers

| Layer | Used by |
|---|---|
| 1 | `CharacterController` (player) |
| 2 | `Enemy` (detected by projectiles) |
| 4 | `Projectile` |
| 8 | `Pickup` |

Masks: the player body masks nothing (movement is manual); enemies use a child
`Area2D` masked to layer 1 to sense the player for contact damage; projectiles
mask layer 2; pickups mask layer 1.

---

## Systems

### `SpawnDirector`

Spawns enemies over time. Each frame it counts down `_spawn_timer`; on expiry it
resets the timer to `_current_interval()` and, if the live enemy count is under
`stage_data.max_enemies`, calls `_spawn_enemy()`. The interval starts at
`spawn_interval` and shrinks by `spawn_ramp` each minute (down to a 0.1s floor),
so the run gets harder.

### `LevelUpSystem`

Generates and applies level-up choices. When `player_leveled_up` fires it builds a
pool of up to 3 random `UpgradeChoice`s:

- upgrades for owned weapons/accessories that aren't max level,
- new weapons/accessories the player doesn't own (capped at 6 of each),
- flat stat boosts from the `STAT_BOOSTS` constant.

It pauses the game, emits `level_up_choices_ready`, and later `apply_choice()`
applies the picked reward, unpauses, and re-checks for a follow-up level.

---

## UI

Both UI layers are built **entirely in code** (no scene files) and driven by
`SignalBus`:

- **`HUD`** (`CanvasLayer`, layer 5) — timer, HP, level and XP bar. Listens to
  `player_hp_changed`, `xp_changed`, `player_leveled_up`, `game_over`, `game_won`.
- **`LevelUpScreen`** (`CanvasLayer`, layer 10) — shows one button per choice.
  Its `process_mode` is `PROCESS_MODE_ALWAYS` so buttons stay clickable while the
  tree is paused.

---

## Content registration

[content/example_content.gd](addons/vss_framework/content/example_content.gd) is a `RefCounted` with a
static `register_all()` that builds every demo definition **in code** and pushes
it into `DataManager`. Its `_stats({"power": 8.0, ...})` helper constructs a
`ModifierStats` from a dictionary of `{property: value}` pairs.

```gdscript
static func _register_weapons() -> void:
    var wand := WeaponData.new()
    wand.id = "wand"
    wand.display_name = "Wand"
    wand.max_level = 8
    wand.base_stats = _stats({"power": 8.0, "cooldown": 1.2, "speed": 400.0, "duration": 2.0, "amount": 1.0})
    wand.level_bonus = _stats({"power": 2.0, "cooldown": -0.08})
    wand.pierce = 0
    wand.weapon_script = preload("res://addons/vss_framework/content/weapons/wand.gd")
    wand.is_area_weapon = false
    DataManager.register_weapon(wand)
```

You can keep registering in code, or build the same objects as `.tres` resources
and edit them in the inspector — either way, gameplay code only ever calls
`DataManager.get_*`.

---

## How to add…

Each recipe below assumes you add files to **your own project** — the examples use
a top-level `content/` folder, but any path works as long as your `preload` points
at it. Register each definition from your own content class (a copy of
`ExampleContent`) or a `.tres` resource, then reference it by id.

### A projectile weapon

1. Create a `Weapon` subclass. For a plain projectile weapon you usually need no
   code at all — the base `_fire()` already launches projectiles:

   ```gdscript
   # content/weapons/laser.gd
   class_name Laser
   extends Weapon
   ## Fires a fast bolt at the nearest enemy. Default _fire() behaviour.
   ```

2. Register a `WeaponData` pointing `weapon_script` at it:

   ```gdscript
   var laser := WeaponData.new()
   laser.id = "laser"
   laser.display_name = "Laser"
   laser.description = "Fires a piercing bolt."
   laser.max_level = 8
   laser.base_stats = _stats({"power": 12.0, "cooldown": 0.9, "area": 8.0, "speed": 600.0, "duration": 1.5, "amount": 1.0})
   laser.level_bonus = _stats({"power": 3.0, "cooldown": -0.06})
   laser.pierce = 1
   laser.weapon_script = preload("res://content/weapons/laser.gd")
   laser.is_area_weapon = false
   DataManager.register_weapon(laser)
   ```

3. To make it a **starting** weapon, add `"laser"` to the character's
   `starting_weapons`. To make it **appear in level-ups**, do nothing — the
   level-up system offers every registered weapon automatically.

### An area weapon

1. Override `_fire()` to damage enemies within `get_area()` instead of firing
   projectiles (see [content/weapons/aura.gd](addons/vss_framework/content/weapons/aura.gd)):

   ```gdscript
   # content/weapons/aura.gd
   class_name Nova
   extends Weapon

   func _fire() -> void:
       var radius := get_area()
       var damage := get_damage()
       for enemy in owner.get_tree().get_nodes_in_group("enemies"):
           if owner.global_position.distance_to(enemy.global_position) <= radius:
               enemy.take_damage(damage)
   ```

2. Register its `WeaponData` with `is_area_weapon = true` (and no
   `projectile_scene`).

### An accessory

1. Create an `Accessory` subclass (usually no override needed):

   ```gdscript
   # content/accessories/berserk_charm.gd
   class_name BerserkCharm
   extends Accessory
   ## Grants bonus damage. Numbers come from its AccessoryData.
   ```

2. Register an `AccessoryData`:

   ```gdscript
   var charm := AccessoryData.new()
   charm.id = "berserk_charm"
   charm.display_name = "Berserk Charm"
   charm.description = "Grants bonus damage."
   charm.max_level = 5
   charm.stats = _stats({"power": 0.10})
   charm.level_bonus = _stats({"power": 0.05})
   charm.accessory_script = preload("res://content/accessories/berserk_charm.gd")
   DataManager.register_accessory(charm)
   ```

### An enemy

1. Create an `Enemy` subclass and override `_draw()` (and movement hooks) for its
   look and behaviour (see [content/enemies/chaser.gd](addons/vss_framework/content/enemies/chaser.gd)):

   ```gdscript
   # content/enemies/ghost.gd
   class_name Ghost
   extends Enemy

   func _draw() -> void:
       draw_circle(Vector2.ZERO, 12.0, Color(0.6, 0.9, 1.0))
   ```

2. Register an `EnemyData`:

   ```gdscript
   var ghost := EnemyData.new()
   ghost.id = "ghost"
   ghost.display_name = "Ghost"
   ghost.max_hp = 15.0
   ghost.move_speed = 120.0
   ghost.contact_damage = 8.0
   ghost.xp_value = 2.0
   ghost.scale = 1.2
   ghost.enemy_script = preload("res://content/enemies/ghost.gd")
   DataManager.register_enemy(ghost)
   ```

3. Add `"ghost"` to a stage's `enemy_pool` so the spawn director can pick it.

### A character

Register a `CharacterData` with its base stats and starting weapons:

```gdscript
var hero := CharacterData.new()
hero.id = "hero"
hero.display_name = "Hero"
hero.description = "Fast and fragile."
hero.base_stats = _stats({"max_hp": 80.0, "move_speed": 260.0})
hero.starting_weapons = ["wand", "laser"]
DataManager.register_character(hero)
```

Then construct it in `main.gd` (or your menu) with
`character.character_data = DataManager.get_character("hero")`.

### A stage

Register a `StageData`:

```gdscript
var stage := StageData.new()
stage.id = "graveyard"
stage.display_name = "Graveyard"
stage.duration_seconds = 420.0
stage.enemy_pool = ["chaser", "ghost", "brute"]
stage.spawn_interval = 1.2
stage.spawn_ramp = 0.12
stage.max_enemies = 180
DataManager.register_stage(stage)
```

Then pass it to `GameManager.start_run(player, DataManager.get_stage("graveyard"))`
and `spawn_director.setup(...)`.

### A stat-boost option

Append a dictionary to the `STAT_BOOSTS` constant in
[systems/level_up_system.gd](addons/vss_framework/systems/level_up_system.gd):

```gdscript
{"stat": "luck", "value": 0.10, "label": "Fortune", "desc": "+10% luck"},
```

The `stat` key must match a `ModifierStats` property, `value` is the flat
increment, and `label`/`desc` are the level-up card text. (Remember that `luck`
is a placeholder unless you wire it up — see below.)

---

## Signals reference

| Signal | Emitted by | Listened to by | Payload |
|---|---|---|---|
| `run_started` | `GameManager.start_run` | (extensibility) | — |
| `game_won` | `GameManager._win` | `HUD` | — |
| `game_over` | `GameManager._lose` | `HUD` | — |
| `player_hp_changed` | `CharacterController.take_damage` | `HUD` | `(current_hp, max_hp)` |
| `player_died` | `CharacterController._die` | `GameManager._lose` | — |
| `player_leveled_up` | `CharacterController._check_level_up` | `HUD`, `LevelUpSystem` | `(new_level)` |
| `xp_changed` | `CharacterController.gain_xp`, `_check_level_up` | `HUD` | `(current_xp, xp_to_next)` |
| `level_up_choices_ready` | `LevelUpSystem._on_player_leveled_up` | `LevelUpScreen` | `(choices: Array)` |
| `level_up_choice_picked` | `LevelUpSystem.apply_choice` | (extensibility) | `(choice: UpgradeChoice)` |
| `enemy_died` | `Enemy.die` | (extensibility) | `(enemy, xp_value)` |
| `pickup_collected` | `Pickup._collect` | (extensibility) | `(pickup)` |

---

## Extension points

These are the seams designed for you to override or subscribe to:

- **Weapon targeting** — override `Weapon._enemies_by_distance()` to change how
  targets are chosen (nearest, random, strongest, etc.).
- **Spawn waves** — override `SpawnDirector._current_interval()` or
  `_spawn_enemy()` for scripted waves or boss events.
- **Level-up pool** — edit `LevelUpSystem.STAT_BOOSTS` and the choice generator.
- **Meta-progression / unlocks** — add a new autoload (register it in
  `project.godot`) that tracks persistent unlocks across runs, and have it
  subscribe to `enemy_died`, `pickup_collected`, `run_started`, etc.
- **Placeholder stats** — `luck`, `greed`, `shields`, `curse`, `thorns`, and the
  rest are unused until you wire them: read them in `CharacterController`
  (e.g. apply `thorns` in `take_damage`, use `luck` in a crit roll) or in your
  own systems.
- **Visuals** — every entity draws a placeholder circle in `_draw()`. Replace with
  `Sprite2D` / `AnimatedSprite2D` and real assets.

---

## Conventions & gotchas

- **`Equipment` is a `RefCounted`, not a `Node`.** Don't add it to the tree; the
  owning `CharacterController` holds it in an array and drives `update()`.
- **`_process` vs `_physics_process`.** Movement, combat and equipment updates use
  `_physics_process` (fixed timestep); timers, spawn pacing and the HUD clock use
  `_process`. Keep that split so pausing and determinism behave.
- **Pause semantics.** `GameManager.pause()` sets `get_tree().paused`. Only nodes
  with `PROCESS_MODE_ALWAYS` (like the level-up screen) keep processing. That's
  how the game freezes behind the choice screen.
- **Spawning.** Use `GameManager.spawn(node)` for anything created at runtime
  (projectiles, pickups, enemies) so it lands in the current scene without a
  world reference.
- **Set `enemy_data` before adding to the tree.** `Enemy._ready()` reads
  `enemy_data`, so assign it before `GameManager.spawn(enemy)` (the spawn director
  already does this).
- **Collision layers** are the table in [the object layer](#collision-layers).
  Keep player=1, enemy=2, projectile=4, pickup=8, or update the masks to match.
- **The three bugs found during review are fixed:** the missing `player_died`
  signal (game over is now reachable), the enemy double-death guard (one gem per
  kill), and the level-up unpause ordering (a second level-up re-pauses correctly).
