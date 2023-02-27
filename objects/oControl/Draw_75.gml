/// @description Insert description here
// You can write your code in this editor

if(keyboard_check(vk_escape)) {
	global.actions.quit = true;
} else {
	global.actions.quit = false;
}

if(keyboard_check_pressed(vk_up)) {
	global.actions.up = true;
} else {
	global.actions.up = false;
}

if(keyboard_check_pressed(vk_down)) {
	global.actions.down = true;
} else {
	global.actions.down = false;
}

if(keyboard_check_pressed(vk_f1)) {
	oCamera.camera.DirectionUp = 0;		
	global.active_model = 0;
}

if(keyboard_check_pressed(vk_f2)) {
	oCamera.camera.DirectionUp = -30;		
}

if(keyboard_check_pressed(vk_f3)) {
	oCamera.camera.DirectionUp = -35.26438968;		
}

if(keyboard_check_pressed(vk_f4)) {
	oCamera.camera.DirectionUp = -45;		
}

if(keyboard_check_pressed(vk_f5)) {
	oCamera.camera.DirectionUp = -90;		
}

if(keyboard_check_pressed(vk_right)) {
	global.actions.right = true;
} else {
	global.actions.right = false;
}

if(keyboard_check_pressed(ord("R"))) {
	global.dorot = !global.dorot;
}

if(keyboard_check_pressed(vk_left)) {
	global.actions.left = true;
} else {
	global.actions.left = false;
}

if(!global.dorot) {
	if(global.actions.right) {
		global.rot-= global.step_angle;
		global.rot = wrap(global.rot, 360);
	}
	if(global.actions.left) {
		global.rot += global.step_angle;
		global.rot = wrap(global.rot, 360);
	}
}

if(global.actions.up) {
	global.active_model++;
	global.active_model = wrap(global.active_model, array_length(global.resources.Tiles));
	oMain.active_model = makeinst(global.resources.Tiles[global.active_model], 0 , 0, 0, oMain.iscale);
}
if(global.actions.down) {
	global.active_model--;
	global.active_model = wrap(global.active_model, array_length(global.resources.Tiles));
	oMain.active_model = makeinst(global.resources.Tiles[global.active_model], 0 , 0, 0, oMain.iscale);
}

if(global.actions.quit) {
	game_end();
}