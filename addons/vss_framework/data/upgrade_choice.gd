class_name UpgradeChoice
extends Resource
## A single option offered on the level-up screen.
##
## A choice is one of: a new weapon, an upgrade to an owned weapon, a new
## accessory, an upgrade to an owned accessory, or a raw stat boost.

enum Kind {
	NEW_WEAPON,
	UPGRADE_WEAPON,
	NEW_ACCESSORY,
	UPGRADE_ACCESSORY,
	STAT_BOOST,
}

## What kind of reward this choice grants.
@export var kind: Kind = Kind.STAT_BOOST

## Title shown on the level-up card.
@export var display_name: String = ""

## Description shown on the level-up card.
@export_multiline var description: String = ""

## For weapon/accessory choices, the data id of the item involved.
@export var item_id: String

## For STAT_BOOST choices, which stat is increased (e.g. "power").
@export var stat_name: String = ""

## For STAT_BOOST choices, how much the stat increases.
@export var stat_value: float = 0.0
