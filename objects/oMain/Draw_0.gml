/// @description Insert description here
// You can write your code in this editor

function get_model(n) {
	n = wrap(global.active_model + n, array_length(global.resources.Tiles));
	return global.resources.Tiles[n];
}

if(global.manymodels) {
	bbmod_material_reset();
//	setpos(active_model,  0, -4 * sin(200/3));
}
bbmod_material_reset();
// setpos(active_model,  0, 0);
active_model.draw(  0, 0);
if(global.manymodels) {
	bbmod_material_reset();
//	self.draw(active_model,  0, 0);
}
 new BBMOD_Matrix().ApplyWorld();

bbmod_material_reset();
