class_name StatEffect
extends Resource
## One named stat effect + amount. Composed into lists on perks (and future content)
## so a single item can bundle several modifiers, each dispatched via StatEffects.

@export var effect: StringName = &""
@export var amount: float = 0.0
