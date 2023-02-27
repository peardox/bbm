// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

// game_set_speed(135, gamespeed_fps);
global.camera_ortho = true;
global.useLicensed = false; // Not included in repo Paid for models
global.manymodels = false;

global.have_camera = false;
global.enable_camera = true;
global.fps = 0;
global.frame = 0;
global.camdir = 0;
global.useinst = true;

global.use_renderer = false;


global.active_model = 0;
global.step_angle = 22.5;

global.size = 256;
global.grid_size = 128;

global.dorot = false;
global.rot = 45;
global.rotctr = 0;
global.rotstep = 1;


if(global.enable_camera) {
  camera_destroy(camera_get_default());
}

window_set_fullscreen(true);


global.resources = {
    Animations: [], // <- Add Animations struct here
    Materials: [],
    Missing: [],
    Models: [],
    Tiles: [],
};

function toscr(v, mscale = 1, theta = undefined, _scale = 1) {
	if(is_undefined(theta)) {
		theta = global.rot;
	}
	var matx = new BBMOD_Matrix()
		.RotateZ(theta)
		.Scale(mscale, mscale, mscale)
		;

	var tp = matrix_transform_vertex(matx.Raw, v.X, v.Y, v.Z);
	var vv = new BBMOD_Vec3(tp[0], tp[1], tp[2]);
	var scr =  oCamera.camera.world_to_screen(vv);
	return {
			X: scr.X * _scale,
			Y: scr.Y * _scale, 
			Z: scr.Z * _scale
	};
}

function wrap(v, max) {
	if(v < 0) {
		v = v % -max;
		v = max + v;
	}
	v = v % max;
	
	return v;
}

function get_hypotenuse(_p1, _p2, _p3) {
	var _width = (_p3.X - _p1.X);
	var _height = (_p1.Y - _p2.Y);
	
	return { hypot: sqrt((_width * _width) + (_height * _height)), width: _width, height: _height };
}

function make_reference_plane(_trial_width = 1, _theta = undefined) {
	if(is_undefined(_theta)) {
		_theta = global.rot;
	}
	
	var _p = array_create(4);
	_p[0] = new BBMOD_Vec3(-0.5, -0.5, 0);
	_p[1] = new BBMOD_Vec3( 0.5, -0.5, 0);
	_p[2] = new BBMOD_Vec3( 0.5,  0.5, 0);
	_p[3] = new BBMOD_Vec3(-0.5,  0.5, 0);

	var _s = array_create(4);
	_s[0] = toscr(_p[0], _trial_width, _theta);
	_s[1] = toscr(_p[1], _trial_width, _theta);
	_s[2] = toscr(_p[2], _trial_width, _theta);
	_s[3] = toscr(_p[3], _trial_width, _theta);

	var _rv = undefined;

	var _leastxval = infinity;
	var _leastyval = infinity;
	var _leastxidx = 0;
	var _leastyidx = 0;
	var _leastxcnt = 0;
	var _leastycnt = 0;
	var _mostxval = -infinity;
	var _mostyval = -infinity;
	var _mostxidx = 0;
	var _mostyidx = 0;
	var _mostxcnt = 0;
	var _mostycnt = 0;
	
	for(var _x = 0; _x < 4; _x++) {
		if(_s[_x].X < _leastxval) {
			_leastxcnt = 0;
			_leastxval = _s[_x].X;
		}
		if(_s[_x].X == _leastxval) {
			_leastxidx = _x;
			_leastxcnt++;
		}
	}

	for(var _y = 0; _y < 4; _y++) {
		if(_s[_y].Y < _leastyval) {
			_leastycnt = 0;
			_leastyval = _s[_y].Y;
		}
		if(_s[_y].Y == _leastyval) {
			_leastyidx = _y;
			_leastycnt++;
		}
	}

	for(var _x = 3; _x >= 0; _x--) {
		if(_s[_x].X > _mostxval) {
			_mostxcnt = 0;
			_mostxval = _s[_x].X;
		}
		if(_s[_x].X == _mostxval) {
			_mostxidx = _x;
			_mostxcnt++;
		}
	}

	for(var _y = 3; _y >= 0; _y--) {
		if(_s[_y].Y > _mostyval) {
			_mostycnt = 0;
			_mostyval = _s[_y].Y;
		}
		if(_s[_y].Y == _mostyval) {
			_mostyidx = _y;
			_mostycnt++;
		}
	}

	var _width = abs(_mostxval - _leastxval);
	var _height = abs(_mostyval - _leastyval);
	if((_leastxcnt == 1) && (_leastycnt == 1)) { // Normal Plane on angle
		// Get bottom left co-ordinates from leftmost and bottommost co-ordinates
		var _bottom_left = { X: _s[_leastxidx].X, Y: _s[_mostyidx].Y };
		
		// Calc the resulting triangle
		// Hypotenuse not definitely needed but may prove useful for adjusting the scale of the base plane of AABB
		var _ref_tri = get_hypotenuse(_bottom_left, _s[_leastxidx], _s[_mostyidx]);
		
		var _prop_width = abs(_ref_tri.width / _width); // Proportional width of Reference Triangle
		var _prop_height = abs(_ref_tri.height / _height); // Proportional width of Reference Triangle
		if(_width == 0) { // Don't Div Zero
			_width = 0.0001;
		}
		
		_rv = { width: _width,
			   height: _height,
			   scale: _trial_width * (_trial_width / (_width)),
			   pwidth: _prop_width,
			   pheight: _prop_height,
			   reftri: _ref_tri,
			 }
			
	} else if((_leastxcnt == 2) && (_leastycnt == 2)) { // Flat Plane
		_rv = { width: _width,
				height: _height,
				scale: _trial_width * (_trial_width / (_width)),
				pwidth: 1,
				pheight: _height / _width,
				reftri: undefined
				} 
	} else if((_leastxcnt == 4) || (_leastycnt == 4)) { // Zero width / height Plane
		_rv = { width: _width,
				height: _height,
				scale: _trial_width * (_trial_width / (_width)),
				pwidth: 1,
				pheight: _height / _width,
				reftri: undefined
				} 
	} else {
		throw("Wierd angles - unhandled - " + string(_leastxcnt) + 
			", " + string(_leastycnt) +
			", " + string(_leastxval) + 
			", " + string(_mostxval) + 
			", " + string(_leastyval) + 
			", " + string(_mostyval) 
		);
	}

	return _rv;
}


function PDX_Model(_file=undefined, trepeat = false, _sha1=undefined) : BBMOD_Model(_file, _sha1) constructor {
	BBox = undefined;
	XSize = undefined;
	YSize = undefined;
	ZSize = undefined;
	Ground = undefined;
	mscale = undefined;
	mname = undefined;
	z = undefined;
	xoff = 0;
	yoff = 0;
	zoff = 0;

	if(!is_undefined(_file)) {
		x = 0;
		y = 0; 
		z = 0;
		mscale = 1;
		mname = __strip_ext(_file);
		var _meshcnt = array_length(Meshes);
		if(_meshcnt > 0) {
			if(!is_undefined(Meshes[0])) {
				BBox = { AMin: new BBMOD_Vec3(Meshes[0].BboxMin.X, Meshes[0].BboxMin.Y, Meshes[0].BboxMin.Z), 
						 AMax: new BBMOD_Vec3(Meshes[0].BboxMax.X, Meshes[0].BboxMax.Y, Meshes[0].BboxMax.Z) };
				for(var _m=1; _m<_meshcnt; _m++) {
					if(!is_undefined(Meshes[_m])) {
						BBox.AMin.X = min(BBox.AMin.X, Meshes[_m].BboxMin.X);
						BBox.AMin.Y = min(BBox.AMin.Y, Meshes[_m].BboxMin.Y);
						BBox.AMin.Z = min(BBox.AMin.Z, Meshes[_m].BboxMin.Z);
						BBox.AMax.X = max(BBox.AMax.X, Meshes[_m].BboxMax.X);
						BBox.AMax.Y = max(BBox.AMax.Y, Meshes[_m].BboxMax.Y);
						BBox.AMax.Z = max(BBox.AMax.Z, Meshes[_m].BboxMax.Z);
					}
				}
			}
		}		
		if(!is_undefined(BBox)) {
			XSize = BBox.AMax.X - BBox.AMin.X;
			YSize = BBox.AMax.Y - BBox.AMin.Y;
			ZSize = BBox.AMax.Z - BBox.AMin.Z;
			Ground = min(BBox.AMax.Z, BBox.AMin.Z);

			var matcnt = array_length(Materials);
			if(matcnt > 1) {
				show_debug_message(mname + " has " + string(matcnt) + " materials");
			}
			var _path = __extract_path(_file);
			for(var m = 0; m < matcnt; m++) {
				if(_path == "") {
					var texfile = MaterialNames[m];
				} else {
					var texfile = _path + "/" + MaterialNames[m];
				}
				var matidx = _get_materials(texfile, trepeat);
		
				if(matidx != -1) {
					Materials[m] = global.resources.Materials[matidx];
				}
			}

		}
	}
	
	static __get_slice_z = function(_z, _scale = 1) { // e.g. _z = model.BBox.AMin.Z
		var _p = array_create(4);
		_p[0] = new BBMOD_Vec3((BBox.AMin.X + xoff) * _scale, (BBox.AMin.Y + yoff) * _scale, (_z + zoff) * _scale);
		_p[1] = new BBMOD_Vec3((BBox.AMin.X + xoff) * _scale, (BBox.AMax.Y + yoff) * _scale, (_z + zoff) * _scale);
		_p[2] = new BBMOD_Vec3((BBox.AMax.X + xoff) * _scale, (BBox.AMin.Y + yoff) * _scale, (_z + zoff) * _scale);
		_p[3] = new BBMOD_Vec3((BBox.AMax.X + xoff) * _scale, (BBox.AMax.Y + yoff) * _scale, (_z + zoff) * _scale);

		var _s = array_create(4);
		for(var _i = 0; _i < 4; _i++) {
			_s[_i] = toscr(_p[_i], mscale);
		}
	
		return _s;
	}
	
	static  __get_bounding_rectangle = function(_scale = 1) {
		var _minz = __get_slice_z(BBox.AMin.Z, _scale);
		var _maxz = __get_slice_z(BBox.AMax.Z, _scale);

		var _minx = min(_minz[0].X, _minz[1].X, _minz[2].X, _minz[3].X, _maxz[0].X, _maxz[1].X, _maxz[2].X, _maxz[3].X);
		var _miny = min(_minz[0].Y, _minz[1].Y, _minz[2].Y, _minz[3].Y, _maxz[0].Y, _maxz[1].Y, _maxz[2].Y, _maxz[3].Y);
		var _maxx = max(_minz[0].X, _minz[1].X, _minz[2].X, _minz[3].X, _maxz[0].X, _maxz[1].X, _maxz[2].X, _maxz[3].X);
		var _maxy = max(_minz[0].Y, _minz[1].Y, _minz[2].Y, _minz[3].Y, _maxz[0].Y, _maxz[1].Y, _maxz[2].Y, _maxz[3].Y);

		return { AMin: { X: _minx, Y: _miny }, AMax: { X: _maxx, Y: _maxy },
				 Width: abs(_maxx - _minx), Height: abs(_maxy - _miny)
			   };
	}

	static __draw_bounds = function(_brect, _colour = c_white) {
		draw_set_color(_colour);

		draw_line(floor(_brect.AMin.X) - 1, floor(_brect.AMin.Y) - 1,  ceil(_brect.AMax.X) + 1, floor(_brect.AMin.Y) - 1); // Top line
		draw_line(floor(_brect.AMin.X) - 1, floor(_brect.AMin.Y) - 1, floor(_brect.AMin.X) - 1,  ceil(_brect.AMax.Y) + 1); // Left line
		draw_line( ceil(_brect.AMax.X) + 1, floor(_brect.AMin.Y) - 1,  ceil(_brect.AMax.X) + 1,  ceil(_brect.AMax.Y) + 1); // Right line 
		draw_line(floor(_brect.AMin.X) - 1,  ceil(_brect.AMax.Y) + 1,  ceil(_brect.AMax.X) + 1,  ceil(_brect.AMax.Y) + 1); // Bottom line
	}
	
	static __fit_size = function() {
		var _size = max(XSize, YSize, ZSize);
//		var _size = max(XSize, YSize);
		return _size;
	}

	static DrawBoundingRect = function(_colour = c_white) {
		var _size = 1; //__fit_size();
		var _brect = __get_bounding_rectangle(_size);
		__draw_bounds(_brect, _colour);	
		
		return _brect;
	}
	
	static DrawBoundingBox =  function(_colour = c_red) {
		draw_set_color(_colour);
		
		var _size = 1; //__fit_size();
	
		var _minz = __get_slice_z(BBox.AMin.Z, _size);
		var _maxz = __get_slice_z(BBox.AMax.Z, _size);

		draw_line(_minz[0].X, _minz[0].Y, _minz[1].X, _minz[1].Y);
		draw_line(_minz[0].X, _minz[0].Y, _minz[2].X, _minz[2].Y);
		draw_line(_minz[3].X, _minz[3].Y, _minz[1].X, _minz[1].Y);
		draw_line(_minz[3].X, _minz[3].Y, _minz[2].X, _minz[2].Y);

		draw_line(_minz[0].X, _minz[0].Y, _maxz[0].X, _maxz[0].Y);
		draw_line(_minz[1].X, _minz[1].Y, _maxz[1].X, _maxz[1].Y);
		draw_line(_minz[2].X, _minz[2].Y, _maxz[2].X, _maxz[2].Y);
		draw_line(_minz[3].X, _minz[3].Y, _maxz[3].X, _maxz[3].Y);

		draw_line(_maxz[0].X, _maxz[0].Y, _maxz[1].X, _maxz[1].Y);
		draw_line(_maxz[0].X, _maxz[0].Y, _maxz[2].X, _maxz[2].Y);
		draw_line(_maxz[3].X, _maxz[3].Y, _maxz[1].X, _maxz[1].Y);
		draw_line(_maxz[3].X, _maxz[3].Y, _maxz[2].X, _maxz[2].Y);
	}

	static draw = function(_scr_x = 0, _scr_y = 0) {
//		var _t = __fit_size();
		var _magic = make_reference_plane(global.size / max(XSize, YSize));
		mscale = _magic.scale;
		new BBMOD_Matrix()
			.Translate(x + xoff, y + yoff, z + zoff)
			.RotateZ(global.rot)
			.Scale(mscale, mscale, mscale)
			.ApplyWorld();
		if(global.use_renderer) {		
			render();
		} else {
			submit();
		}
	}
	
	
	static clone = function () {
		var _clone = new PDX_Model();
		copy(_clone);

		_clone.BBox = BBox;
		_clone.XSize = XSize;
		_clone.YSize = YSize;
		_clone.ZSize = ZSize;
		_clone.Ground = Ground;
		_clone.mscale = mscale;
		_clone.mname = mname;
		_clone.x = 0;
		_clone.y = 0;
		_clone.z = 0;
		
		return _clone;
	};

	static __strip_ext = function(_fname) {
		var _v = filename_name(_fname);
		return string_copy(_v, 1, string_length(_v) - string_length(filename_ext(_v)));
	}

	static __extract_path = function(_fname) {
		var _v = string_length(filename_name(_fname));
		var _p = string_copy(_fname, 1, string_length(_fname) - _v);
		if(string_char_at(_p, string_length(_p) - 1) == "/") {
			_p = string_copy(_fname, 1, string_length(_p) - 1);
		}
		if(string_char_at(_p, string_length(_p) - 1) == "\\") {
			_p = string_copy(_fname, 1, string_length(_p) - 1);
		}
		return _p;
	}

	
	static _get_materials = function(matfile, trepeat = false) {
		var matimg = false;
	
		if(file_exists(matfile + ".png")) {
			matimg = matfile + ".png";
		} else if(file_exists(matfile + ".jpg")) {
			matimg = matfile + ".jpg";
		}
	
		if(is_string(matimg)) {
			var matcnt = array_length(global.resources.Materials);
			for(var i = 0; i<matcnt; i++) {
				if(global.resources.Materials[i].matname == matimg) {
					return i;
				}
			}
			var sprtex = sprite_add(matimg, 0, false, true, 0, 0);
			sprite_prefetch(sprtex);
			global.resources.Materials[matcnt] = BBMOD_MATERIAL_DEFAULT.clone();
			if(global.use_renderer) {		
				global.resources.Materials[matcnt].set_shader(BBMOD_ERenderPass.DepthOnly, BBMOD_SHADER_DEFAULT_DEPTH);
			}
			global.resources.Materials[matcnt].matname = matimg;
			global.resources.Materials[matcnt].BaseOpacity = sprite_get_texture(sprtex, 0);
			global.resources.Materials[matcnt].Repeat = trepeat;
			return matcnt;
		} else {
			var already_missed = false;
			var miscnt = array_length(global.resources.Missing);
			for(var i=0; i<miscnt; i++) {
				if(global.resources.Missing[i] == matfile) {
					already_missed = true;
				}
			}
			if(!already_missed) {
				global.resources.Missing[miscnt] = matfile;		
				show_debug_message("Missing material : " + matfile + " in " + mname);
			}
		}
		return -1;
	}

}
	

function cachemodel(mname, path, trepeat) {
	var model = undefined;
	if(path == "") {
		var mfile = mname + ".bbmod";
	} else {
		var mfile = path + "/" + mname + ".bbmod";
	}
	if(file_exists(mfile)) {
			model = new PDX_Model(mfile, trepeat);

	} else {
		throw("Missing model " + mfile);
	}
	
	return model;
}

function makeinst(inst, xpos = 0, ypos = 0, zpos = 0, scale = 1, debug = false) {
	var model = inst.clone();


	model.xpos = 0; //xpos;
	model.ypos = 0; 

	model.xoff = -(model.BBox.AMin.X + (model.XSize / 2));
	model.yoff = -(model.BBox.AMin.Y + (model.YSize / 2));
	model.zoff = -model.Ground - abs(model.ZSize / 2);

	model.mscale = global.magic.scale; // window_get_height() / (model.mrad * 2); // scale;
	model.freeze();
	
	return model;
}

function fit_size(_model) {
	return max(_model.XSize, _model.YSize);
}

function setpos(model, _ox = 0, _oy = 0) {
	var t = fit_size(model);
//	global.magic = make_reference_plane(global.size / t);
//	var br = model.__get_bounding_rectangle();
	model.mscale = global.magic.scale; // * (global.size / br.Width);
	new BBMOD_Matrix()
		.Translate(model.x + model.xoff, model.y + model.yoff, model.z + model.zoff)
		.RotateZ(global.rot)
		.Scale(model.mscale, model.mscale, model.mscale)
		.ApplyWorld();
	if(global.use_renderer) {		
		model.render();
	} else {
		model.submit();
	}
}

function strip_ext(fname) {
	return string_copy(fname, 1, string_length(fname) - string_length(filename_ext(fname)));
}

function load_models_from(dir, trepeat = false) {
	var i = array_length(global.resources.Tiles);
	var cnt = 0;
	
	var bfile = file_find_first(dir + "\\*.bbmod", fa_none); 
	
	if (bfile != "") {
		while (bfile != "") {
			global.resources.Tiles[i++] = cachemodel(strip_ext(bfile), dir, trepeat);
			bfile = file_find_next();
			cnt++;
		}

	} else {
		throw("No Files");
	}
	
	file_find_close();

	return cnt;
}

global.magic = undefined;

if(global.useinst) {
	var i = 0;
	var cnt = 0;
	global.resources.Tiles[i++] = cachemodel("transrefplane", working_directory);
	
	if(global.useLicensed) {
//		cnt += load_models_from("D:\\blend\\test\\Retro-Desert");
//		cnt += load_models_from("D:\\blend\\test\\Retro-Dungeons");
		cnt += load_models_from("D:\\blend\\test\\Retro-Forest");
		cnt += load_models_from("D:\\blend\\test\\Retro-Gothic");
		cnt += load_models_from("D:\\blend\\test\\Retro-Interiors");
		cnt += load_models_from("D:\\blend\\test\\Retro-Spaceship");
		cnt += load_models_from("D:\\blend\\test\\Retro-Village");
		cnt += load_models_from("D:\\blend\\test\\Retro-Winter");
		cnt += load_models_from("D:\\blend\\test\\DMKit"); 
		cnt += load_models_from("D:\\blend\\test\\Molten-Chasm");
		cnt += load_models_from("D:\\blend\\test\\Refplane"); 

		
		global.active_model = 1;
	} else {
		cnt += load_models_from(working_directory + "Kenney/RetroMedievalKit", true); 
		cnt += load_models_from("D:\\blend\\test\\Refplane"); 
	}
}


show_debug_message("Tiles = " + string(cnt));

global.p_string = false;

var p_num;
p_num = parameter_count();
if(p_num > 0) {
	global.p_string = array_create(p_num);
    var i;
    for (i = 0; i < p_num; i += 1)
    {
        global.p_string[i] = parameter_string(i + 1);
    }
}
