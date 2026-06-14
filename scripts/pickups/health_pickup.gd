extends BasePickup


func collect(player: Node) -> void:
	var amount := definition.value if definition else 15
	var health := player.get_node_or_null("HealthComponent") as HealthComponent
	if health:
		health.heal(amount)
	super.collect(player)
