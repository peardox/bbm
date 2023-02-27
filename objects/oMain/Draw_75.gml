/// @description Insert description here
// You can write your code in this editor
if(global.dorot) {
	global.rotctr++
	if((global.rotctr % global.rotstep) == 0) {
		global.rot++;
		global.rotctr = 0;
		}
	}
if(global.rot > 360) {
	global.rot = 0;
}

