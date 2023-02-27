/// @description Insert description here
// You can write your code in this editor



iscale = global.size;
active_model = makeinst(global.resources.Tiles[global.active_model], 0, 0, 0, iscale);
if(global.manymodels) {
	model1 = makeinst(global.resources.Tiles[global.active_model + 1], 0 , 0, 0, iscale);
	model2 = makeinst(global.resources.Tiles[global.active_model + 2], 0 , 0, 0, iscale);
}
