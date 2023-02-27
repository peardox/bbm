/// @description Insert description here
// You can write your code in this editor
if(global.useinst) {

	new BBMOD_Matrix()
		.Translate(x, y, z)
		.RotateZ(global.rot)
		.RotateX(0)
		.Scale(mscale, mscale, mscale)
		.Translate(0, 0, 0)
		.ApplyWorld();
show_debug_message("Draw oTile");
	
}