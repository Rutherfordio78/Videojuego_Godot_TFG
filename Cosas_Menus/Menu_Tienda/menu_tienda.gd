extends Control


func _process(delta: float) -> void:
	$ScrollContainer/VBoxContainer/Vida/Label2.text = "💰 "+str(Global.precio_vida)
	$"ScrollContainer/VBoxContainer/Daño/Label2".text = "💰 "+str(Global.precio_daño)
	$ScrollContainer/VBoxContainer/Cura/Label2.text = "💰 "+str(Global.precio_cura)
	$ScrollContainer/VBoxContainer/Prb_Crit/Label2.text = "💰 "+str(Global.precio_Prb_Crit)
	$ScrollContainer/VBoxContainer/Crit_Dmg/Label2.text = "💰 "+ str(Global.precio_Crit_Dmg)
	$ScrollContainer/VBoxContainer/Municion_Maxima/Label2.text = "💰 "+ str(Global.precio_Ammo_Max)
	$ScrollContainer/VBoxContainer/Municion/Label2.text = "💰 "+ str(Global.precio_Ammo)

func _on_comprar_vida_pressed() -> void:
	if EstadisticasPlayer.monedas >= Global.precio_vida:
		EstadisticasPlayer.Vida_Maxima_Player += EstadisticasPlayer.Vida_Maxima_Player * 0.06
		EstadisticasPlayer.vida_actual_Player = EstadisticasPlayer.Vida_Maxima_Player
		EstadisticasPlayer.monedas -= Global.precio_vida
		Global.precio_vida += Global.precio_vida * 0.05


func _on_comprar_daño_pressed() -> void:
	if EstadisticasPlayer.monedas >= Global.precio_daño:
		EstadisticasPlayer.Buffo_De_Daño_Player += 0.2
		EstadisticasPlayer.monedas -= Global.precio_daño
		Global.precio_daño += Global.precio_daño * 0.05
		


func _on_comprar_cura_pressed() -> void:
	if EstadisticasPlayer.monedas >= Global.precio_cura:
		EstadisticasPlayer.vida_actual_Player = clamp(EstadisticasPlayer.vida_actual_Player + 20, 0, EstadisticasPlayer.Vida_Maxima_Player)
		EstadisticasPlayer.monedas -= Global.precio_cura


func _on_comprar_prb_crit_pressed() -> void:
	if EstadisticasPlayer.monedas >= Global.precio_Prb_Crit:
		EstadisticasPlayer.Probabilidad_Critico += 0.05
		EstadisticasPlayer.monedas -= Global.precio_Prb_Crit
		Global.precio_Prb_Crit += Global.precio_Prb_Crit * 0.06


func _on_comprar_crit_dmg_pressed() -> void:
	if EstadisticasPlayer.monedas >= Global.precio_Crit_Dmg:
		EstadisticasPlayer.Daño_Critico += 0.2
		EstadisticasPlayer.monedas -= Global.precio_Crit_Dmg
		Global.precio_Crit_Dmg += Global.precio_Crit_Dmg * 0.06


func _on_comprar_ammo_max_pressed() -> void:
	if EstadisticasPlayer.monedas >= Global.precio_Ammo_Max:
		EstadisticasPlayer.municion_maxima += 1
		EstadisticasPlayer.municion += 1
		EstadisticasPlayer.monedas -= Global.precio_Ammo_Max
		Global.precio_Ammo_Max += Global.precio_Ammo_Max * 0.05


func _on_comprar_ammo_pressed() -> void:
	if EstadisticasPlayer.monedas >= Global.precio_Ammo and EstadisticasPlayer.municion < EstadisticasPlayer.municion_maxima:
		EstadisticasPlayer.municion += 1
		EstadisticasPlayer.monedas -= Global.precio_Ammo
		Global.precio_Ammo += Global.precio_Ammo * 0.05
