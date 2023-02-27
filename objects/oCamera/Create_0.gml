

if(global.camera_ortho) {
	camera = new BBMOD_Camera();
	camera.Width = window_get_width();
	camera.Height = window_get_height();
	camera.Orthographic = true;
	camera.ZNear = -32767;
	camera.Direction = global.camdir;
	camera.DirectionUp = -45;
} else {	
	camera = new BBMOD_Camera();
	camera.Offset = new BBMOD_Vec3(200, 200, -200);
	camera.Target = new BBMOD_Vec3(0, 0, 0);
//		camera.Roll = radtodeg(-0.79456);
//		camera.Direction = -global.camdir;
//		camera.DirectionUp = -global.camdir;
//		camera.FollowObject = model[0];
	camera.Zoom = 0.02;
	camera.Fov = 60;
}

global.have_camera = true;

if(is_undefined(global.magic)) {
	global.magic = make_reference_plane(global.size);
}

if(global.use_renderer) {
renderer = new BBMOD_DefaultRenderer();
// renderer.EnableShadows = true;
renderer.UseAppSurface = true;
renderer.RenderScale = 1;

// Enable SSAO
renderer.EnableGBuffer = true;
// renderer.EnableSSAO = true;
// renderer.SSAOPower = 3;
// renderer.SSAODepthRange = 0.5;
// renderer.SSAOBlurDepthRange = 0.1;
}