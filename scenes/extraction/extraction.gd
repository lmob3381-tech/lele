extends Control

@onready var result_title: Label = $CenterContainer/VBoxContainer/ResultTitle
@onready var time_label: Label = $CenterContainer/VBoxContainer/StatsBox/VBoxContainer/TimeLabel
@onready var items_label: Label = $CenterContainer/VBoxContainer/StatsBox/VBoxContainer/ItemsLabel
@onready var damage_label: Label = $CenterContainer/VBoxContainer/StatsBox/VBoxContainer/DamageLabel
@onready var encounters_label: Label = $CenterContainer/VBoxContainer/StatsBox/VBoxContainer/EncountersLabel
@onready var score_label: Label = $CenterContainer/VBoxContainer/ScoreLabel
@onready var return_btn: Button = $CenterContainer/VBoxContainer/ReturnBtn

var mission_result: Dictionary = {
	"success": true,
	"time_survived": 300,
	"items_collected": 5,
	"items_total": 5,
	"damage_taken": 20,
	"pocong_encountered": 3,
	"score": 1500
}

var current_score: float = 0.0
var target_score: float = 0.0

func _ready() -> void:
	if GlobalData and GlobalData.has("mission_result"):
		mission_result = GlobalData.get("mission_result")
		
	if mission_result.get("success", false):
		result_title.text = "MISI SELESAI"
		result_title.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
	else:
		result_title.text = "MISI GAGAL"
		result_title.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2))
		
	var t = int(mission_result.get("time_survived", 0))
	time_label.text = "Time Survived: %02d:%02d" % [t / 60, t % 60]
	items_label.text = "Items Collected: %d/%d" % [mission_result.get("items_collected", 0), mission_result.get("items_total", 5)]
	damage_label.text = "Damage Taken: " + str(mission_result.get("damage_taken", 0))
	encounters_label.text = "Pocong Encountered: " + str(mission_result.get("pocong_encountered", 0))
	
	target_score = mission_result.get("score", 0)
	
	return_btn.pressed.connect(_on_return_pressed)

func _process(delta: float) -> void:
	if current_score < target_score:
		current_score += target_score * delta * 2.0
		if current_score > target_score:
			current_score = target_score
		score_label.text = "Score: " + str(int(current_score))

func _on_return_pressed() -> void:
	if has_node("/root/SceneManager"):
		get_node("/root/SceneManager").change_scene(get_node("/root/SceneManager").LOBBY)
	else:
		get_tree().change_scene_to_file("res://scenes/lobby/lobby.tscn")
