/// @description Insert description here
// You can write your code in this editor
if(global.have_camera) {
	// Do not forget to call the camera's update method
	camera.update(delta_time);
	camera.apply(); 
/*
	global.magic = make_reference_plane(512 /  max(
		global.resources.Tiles[global.active_model].Meshes[0].BboxMax.X - global.resources.Tiles[global.active_model].Meshes[0].BboxMin.X, 
		global.resources.Tiles[global.active_model].Meshes[0].BboxMax.Y - global.resources.Tiles[global.active_model].Meshes[0].BboxMin.Y));
*/
}

if(global.use_renderer) {
	renderer.update(delta_time);
}

if((global.frame % 60) == 15) {
	global.fps = fps_real;
}
global.frame++;
