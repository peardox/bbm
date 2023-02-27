function get_slice_z(model, _z) { // e.g. _z = model.BBox.AMin.Z
	var _p = array_create(4);
	_p[0] = new BBMOD_Vec3(model.BBox.AMin.X + model.xoff, model.BBox.AMin.Y + model.yoff, _z + model.zoff);
	_p[1] = new BBMOD_Vec3(model.BBox.AMin.X + model.xoff, model.BBox.AMax.Y + model.yoff, _z + model.zoff);
	_p[2] = new BBMOD_Vec3(model.BBox.AMax.X + model.xoff, model.BBox.AMin.Y + model.yoff, _z + model.zoff);
	_p[3] = new BBMOD_Vec3(model.BBox.AMax.X + model.xoff, model.BBox.AMax.Y + model.yoff, _z + model.zoff);

	var _s = array_create(4);
	for(var _i = 0; _i < 4; _i++) {
		_s[_i] = toscr(_p[_i], model.mscale);
	}
	
	return _s;
}

function get_slice_y(model, _y) { // e.g. _y = model.BBox.AMin.Y
	var _p = array_create(4);
	_p[0] = new BBMOD_Vec3(model.BBox.AMin.X + model.xoff, _y + model.yoff, model.BBox.AMin.Z + model.zoff);
	_p[1] = new BBMOD_Vec3(model.BBox.AMin.X + model.xoff, _y + model.yoff, model.BBox.AMax.Z + model.zoff);
	_p[2] = new BBMOD_Vec3(model.BBox.AMax.X + model.xoff, _y + model.yoff, model.BBox.AMin.Z + model.zoff);
	_p[3] = new BBMOD_Vec3(model.BBox.AMax.X + model.xoff, _y + model.yoff, model.BBox.AMax.Z + model.zoff);

	var _s = array_create(4);
	for(var _i = 0; _i < 4; _i++) {
		_s[_i] = toscr(_p[_i], model.mscale);
	}
	
	return _s;
}

function get_slice_x(model, _x) { // e.g. _x = model.BBox.AMin.X
	var _p = array_create(4);
	_p[0] = new BBMOD_Vec3(_x + model.xoff, model.BBox.AMin.Y + model.yoff, model.BBox.AMin.Z + model.zoff);
	_p[1] = new BBMOD_Vec3(_x + model.xoff, model.BBox.AMin.Y + model.yoff, model.BBox.AMax.Z + model.zoff);
	_p[2] = new BBMOD_Vec3(_x + model.xoff, model.BBox.AMax.Y + model.yoff, model.BBox.AMin.Z + model.zoff);
	_p[3] = new BBMOD_Vec3(_x + model.xoff, model.BBox.AMax.Y + model.yoff, model.BBox.AMax.Z + model.zoff);

	var _s = array_create(4);
	for(var _i = 0; _i < 4; _i++) {
		_s[_i] = toscr(_p[_i], model.mscale);
	}
	
	return _s;
}

function get_bounding_rectangle(model) {
	var _minz = get_slice_z(model, model.BBox.AMin.Z);
	var _maxz = get_slice_z(model, model.BBox.AMax.Z);

	var _minx = min(_minz[0].X, _minz[1].X, _minz[2].X, _minz[3].X, _maxz[0].X, _maxz[1].X, _maxz[2].X, _maxz[3].X);
	var _miny = min(_minz[0].Y, _minz[1].Y, _minz[2].Y, _minz[3].Y, _maxz[0].Y, _maxz[1].Y, _maxz[2].Y, _maxz[3].Y);
	var _maxx = max(_minz[0].X, _minz[1].X, _minz[2].X, _minz[3].X, _maxz[0].X, _maxz[1].X, _maxz[2].X, _maxz[3].X);
	var _maxy = max(_minz[0].Y, _minz[1].Y, _minz[2].Y, _minz[3].Y, _maxz[0].Y, _maxz[1].Y, _maxz[2].Y, _maxz[3].Y);

	return { min: { X: _minx, Y: _miny }, max: { X: _maxx, Y: _maxy }};
}

function draw_slice_z(_s, _colour = c_green) {
	draw_set_color(_colour);
	
	draw_line(_s[0].X, _s[0].Y, _s[1].X, _s[1].Y);
	draw_line(_s[0].X, _s[0].Y, _s[2].X, _s[2].Y);
	draw_line(_s[3].X, _s[3].Y, _s[1].X, _s[1].Y);
	draw_line(_s[3].X, _s[3].Y, _s[2].X, _s[2].Y);
}

