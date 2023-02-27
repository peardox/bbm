/// @description Insert description here
// You can write your code in this editor

// 2D Limits
var _br = active_model.DrawBoundingRect();
if(global.manymodels) {
	model1.DrawBoundingRect();
	model2.DrawBoundingRect();
}

// 3D Bounding Box
active_model.DrawBoundingBox();

draw_set_color(c_white);

draw_text(8, 8, "Frame = " + string(global.frame) + ", FPS = " + string(fps) + 
			", Real = " + string(global.fps) + ", Rot = " + string(global.rot) +
			", MId = " + string(global.active_model) + ", Name = " + active_model.mname);

draw_text(8, 24, "Scale : " + string(active_model.mscale) + " Magic = " + string(global.magic));	
draw_text(8, 40, string(active_model.BBox));
if(global.manymodels) {
	draw_text(8, 72, string(model1.BBox));
	draw_text(8, 88, string(model2.BBox));
} else {
	draw_text(8, 72, "XSize : " + string(active_model.XSize) + ", YSize : " + string(active_model.YSize) +
					 ", ZSize : " + string(active_model.ZSize));
	draw_text(8, 88, "BRect : " + string(_br));
}

draw_text(8, display_get_height() - 24, "Objects = " + string(array_length(global.resources.Tiles)));


/*	

if(is_array(global.p_string)) {
	var txt = "Args : ";
	for(var i =0; i<array_length(global.p_string); i++) {
		txt += " " + global.p_string[i];
	}
	draw_text(8, 104, txt);
}
*/
if(array_length(global.resources.Missing) > 0) {
	draw_text(8, 136, "Missing image textures (" + string(array_length(global.resources.Missing)) + ")");
	for(var i = 0; i < array_length(global.resources.Missing); i++) {
		draw_text(8, 152 + (i * 16), global.resources.Missing[i]);
	}
}



// Ground Grid
/*
var l = wireframe(active_model.Meshes[0].BboxMin.Z, active_model.mscale);
draw_set_color(c_red);
draw_line(l[0].X, l[0].Y, l[1].X, l[1].Y);
draw_line(l[1].X, l[1].Y, l[2].X, l[2].Y);
draw_line(l[2].X, l[2].Y, l[3].X, l[3].Y);
draw_line(l[3].X, l[3].Y, l[0].X, l[0].Y);
	
var l = wireframe(active_model.Meshes[0].BboxMax.Z, active_model.mscale);
draw_set_color(c_blue);
draw_line(l[0].X, l[0].Y, l[1].X, l[1].Y);
draw_line(l[1].X, l[1].Y, l[2].X, l[2].Y);
draw_line(l[2].X, l[2].Y, l[3].X, l[3].Y);
draw_line(l[3].X, l[3].Y, l[0].X, l[0].Y);
*/
