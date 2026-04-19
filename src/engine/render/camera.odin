package render

import "core:math/linalg"
import gl "vendor:OpenGL"

camera_pos: [3]f32
camera_rot: quaternion128
camera_fov: f32
camera_near: f32
camera_far: f32

CameraData :: struct {
	perspective: linalg.Matrix4x4f32,
	translation: linalg.Matrix4x4f32,
	rotation:    linalg.Matrix4x4f32,
}

set_camera_view_full :: proc(pos: [3]f32, rot: quaternion128, fov: f32, near: f32, far: f32) {

	camera_pos = pos
	camera_rot = rot
	camera_fov = fov
	camera_near = near
	camera_far = far

	aspect: f32 = 1.0

	perspective := linalg.matrix4_perspective_f32(fov, aspect, near, far, false)
	view_translation := linalg.matrix4_translate(camera_pos)
	view_rotation := linalg.matrix4_from_quaternion(rot)

	// Update shaders with new view data.
	view_data: CameraData = {
		perspective = perspective,
		translation = view_translation,
		rotation    = view_rotation,
	}

	gl.BindBuffer(gl.UNIFORM_BUFFER, ubo_camera_view)
	gl.BufferSubData(gl.UNIFORM_BUFFER, 0, size_of(CameraData), &view_data)
	gl.BindBuffer(gl.UNIFORM_BUFFER, 0)

	gl.BindBufferBase(gl.UNIFORM_BUFFER, CAMERA_VIEW_CHANNEL, ubo_camera_view)
}

set_camera_transform :: proc(pos: [3]f32, rot: quaternion128) {

	set_camera_view_full(pos, rot, camera_fov, camera_near, camera_far)
}

set_camera :: proc {
	set_camera_view_full,
	set_camera_transform,
}
