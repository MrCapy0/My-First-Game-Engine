package app

import "vendor:raylib"

InitSettings :: struct {
	window_title:  cstring,
	window_width:  i32,
	window_height: i32,
}

@(private)
camera_3d: raylib.Camera3D = raylib.Camera3D {
	fovy       = 60,
	position   = {0, 2, -5},
	projection = raylib.CameraProjection.PERSPECTIVE,
	target     = {0, 0, 0},
	up         = {0, 1, 0},
}

set_camera_3d :: #force_inline proc(position: raylib.Vector3, direction: raylib.Vector3) {
	camera_3d.position = position
	camera_3d.target = position + direction
}

get_camera_3d :: #force_inline proc() -> raylib.Camera3D {
	return camera_3d
}

get_delta :: #force_inline proc() -> f32 {
	return raylib.GetFrameTime()
}
