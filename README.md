# VSS Framework

A reusable **Godot 4 / GDScript 2.0** framework for building horde-survival
(bullet-heaven) games, packaged as a **Godot addon**.

It provides the core architecture of the genre — a data-driven character with
auto-firing weapons and passive accessories, hordes of enemies, experience
gems, level-up choices, and a timed stage — as clean, commented, and extensible
GDScript. It ships with a small set of example content so it runs immediately,
and you build your own game on top of it.

## Requirements

- [Godot](https://godotengine.org/) 4.3 or newer (GDScript 2.0).

## Installing as an addon

1. Copy the `addons/vss_framework/` folder into your own project's `addons/`
   directory (so it sits at `res://addons/vss_framework/`).
2. Open your project and go to **Project → Project Settings → Plugins**.
3. Enable **VSS Framework**.

Enabling the plugin automatically registers the three framework singletons
(`SignalBus`, `DataManager`, `GameManager`) and makes all of the framework's
`class_name` classes available. From there you subclass the framework's classes,
register your own content, and build your own main scene — see the
[Usage Guide](GUIDE.md) for the full walkthrough, and the demo under
`addons/vss_framework/demo/` for a working reference.

## Running the demo

1. Open this folder in Godot (it is already a project).
2. Enable the plugin: **Project → Project Settings → Plugins → VSS Framework → Enable**.
3. Press **F5** (or the Play button).

Controls: move with **WASD** or the **arrow keys**. Enemies spawn, chase you,
and drop green gems. Collect gems to level up and pick one of three upgrades.
Survive until the timer runs out to win.

> **Why enable the plugin first?** The autoloads are registered by the plugin,
> not by `project.godot`, so the demo needs the plugin enabled to run.

## Project structure

```
vss framework/
├── project.godot                Godot project config (main scene → addon demo)
├── addons/
│   └── vss_framework/           The framework, as a Godot addon
│       ├── plugin.cfg           Addon metadata
│       ├── plugin.gd            Registers the autoloads on enable
│       ├── autoload/            Singletons (event bus, data, game state)
│       │   ├── signal_bus.gd    Global signals — systems talk through this
│       │   ├── data_manager.gd  Registry of all data definitions
│       │   └── game_manager.gd  Run state, timer, win/lose conditions
│       ├── data/                Resource-based data definitions
│       │   ├── modifier_stats.gd  The stat bag (power, area, cooldown, …)
│       │   ├── character_data.gd
│       │   ├── weapon_data.gd
│       │   ├── accessory_data.gd
│       │   ├── enemy_data.gd
│       │   ├── stage_data.gd
│       │   └── upgrade_choice.gd
│       ├── objects/             Runtime gameplay objects
│       │   ├── equipment.gd       Base for weapons & accessories
│       │   ├── weapon.gd          Auto-firing weapon (projectile targeting)
│       │   ├── accessory.gd       Passive stat source
│       │   ├── character_controller.gd  The player
│       │   ├── enemy.gd           Chasing enemy
│       │   ├── projectile.gd      Weapon projectile
│       │   └── pickup.gd          Experience gem
│       ├── systems/
│       │   ├── spawn_director.gd  Enemy spawn pacing / difficulty ramp
│       │   └── level_up_system.gd Generates & applies level-up choices
│       ├── ui/
│       │   ├── hud.gd             Timer / HP / level / XP bar
│       │   └── level_up_screen.gd Three-choice level-up picker
│       ├── content/             Example content (replace with your own)
│       │   ├── example_content.gd  Registers the demo character/weapons/etc.
│       │   ├── weapons/  wand.gd, aura.gd
│       │   ├── accessories/  vitality_amulet.gd
│       │   └── enemies/  chaser.gd, brute.gd
│       └── demo/                The runnable sample (main.gd + main.tscn)
├── GUIDE.md                     Deep usage guide
├── GUIDE.html                   Styled HTML version of the guide
└── icon.svg                     Project icon
```

## Architecture

### Autoloads

The three autoloads are registered by `plugin.gd` when you enable the addon:

- **`SignalBus`** — every cross-system event is a signal here (enemy died,
  player levelled up, game over, …). Systems subscribe to `SignalBus` instead
  of reaching into each other.
- **`DataManager`** — holds the dictionaries of registered data, keyed by
  string id.
- **`GameManager`** — owns the active player, the stage, the elapsed timer, and
  the victory/defeat transitions.

### Data-driven design

Everything that varies between characters/weapons/enemies is data, not code:

- **`ModifierStats`** is the shared stat bag. Each stat is an exported float.
- **`CharacterData` / `WeaponData` / `AccessoryData` / `EnemyData` /
  `StageData`** describe one thing each and are registered by id.
- Content is registered in `ExampleContent.register_all()`; you can instead load
  `.tres` resources if you prefer editing data in the inspector.

### Equipment hierarchy

```
Equipment (RefCounted)
├── Weapon    — auto-fires on a cooldown; overrides _fire() to change behaviour
└── Accessory — passive; contributes stats to its owner
```

`CharacterController` owns a list of weapons and accessories, drives their
`update(delta)` each frame, and recomputes its effective stats whenever bonuses
change.

### Stat model

A character's effective stats are computed as:

```
effective = base_stats + level_bonus + sum(accessory stats)
```

Weapon numbers are scaled by the owner's global modifiers:

| Owner stat  | Effect on weapons                            |
|-------------|----------------------------------------------|
| `power`     | `damage = weapon.power * (1 + power)`        |
| `cooldown`  | `cooldown = weapon.cooldown * (1 - cooldown)`|
| `area`      | `area = weapon.area * (1 + area)`            |
| `speed`     | `speed = weapon.speed * (1 + speed)`         |
| `duration`  | `duration = weapon.duration * (1 + duration)`|
| `amount`    | `amount = weapon.amount + amount`            |

`max_hp` and `move_speed` are flat values; `magnet` adds to the pickup radius;
`regen` heals per second; `armor` reduces each hit; `growth` boosts XP gain.

## Adding content

Add your own content **in your own project** (outside the addon). The examples
below use a top-level `content/` folder; any path works as long as your
`preload` points at it. Register each definition with `DataManager`, just like
`ExampleContent` does.

### A new weapon

1. Create a subclass of `Weapon` (e.g. `content/weapons/laser.gd`) and override
   `_fire()` if it isn't a plain projectile weapon.
2. Register a `WeaponData` pointing `weapon_script` at that script.

### A new accessory

1. Create a subclass of `Accessory` (usually no override needed).
2. Register an `AccessoryData` with its `stats` and `level_bonus`.

### A new enemy

1. Create a subclass of `Enemy` and override `_draw()` (and movement hooks) for
   its look/behaviour.
2. Register an `EnemyData` pointing `enemy_script` at that script, then add its
   id to a stage's `enemy_pool`.

### A new character

Register a `CharacterData` with its `base_stats` and `starting_weapons`, then
construct it with `character.character_data = DataManager.get_character("id")`.

### A new stage

Register a `StageData` with a duration, enemy pool and spawn settings, then pass
it to `GameManager.start_run(...)`.

## Extension points

- **Weapon targeting** — `Weapon._enemies_by_distance()` is the place to change
  how targets are chosen.
- **Spawn waves** — override `SpawnDirector._current_interval()` /
  `_spawn_enemy()` for scripted waves or boss events.
- **Level-up pool** — edit `LevelUpSystem.STAT_BOOSTS` and the choice generator.
- **Meta-progression / unlocks** — add a new autoload (register it in your own
  `project.godot`) that tracks persistent unlocks across runs.
- **Visuals** — every entity draws a placeholder shape in `_draw()`; replace
  with `Sprite2D`/`AnimatedSprite2D` and real assets.

## Documentation

See [GUIDE.md](GUIDE.md) for the deep walkthrough — what connects to what,
the full signals reference, and step-by-step recipes for adding weapons,
accessories, enemies, characters and stages.
