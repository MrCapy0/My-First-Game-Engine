package player

import console "../../../console"
import lmath "../../../lmath"
import render "../../../render"
import window "../../../window"

FlyCameraData :: struct {
	view:            render.ViewSettings,
	look_euler:      lmath.V2,
	smooth_move_dir: lmath.V3,
}

mob_transform: lmath.Transform
fly_camera_data: FlyCameraData

CAMERA_LOOK_SPEED: f32 : 0.001
FLY_CAMERA_MAX_SPEED: f32 : 5.0
FLY_CAMERA_ACCELERATION: f32 : 3.0

start :: proc() {

	fly_camera_data.view = {
		near = 0.02,
		far = 10000,
		fov = 60,
		transform = {pos = lmath.V3_ZERO, rot = lmath.Q_Identity},
	}

	fly_camera_data.smooth_move_dir = lmath.V3_ZERO

	render.set_view(fly_camera_data.view)
	//window.set_cursor_visible(false)
	window.set_cursor_enabled(false)
}

update :: proc(dt: f32) {
	update_fly_camera(dt)
}

@(private)
update_fly_camera :: proc(dt: f32) {

	// Movement.
	w_pressed := window.is_key_down(window.KEYS.W)
	a_pressed := window.is_key_down(window.KEYS.A)
	s_pressed := window.is_key_down(window.KEYS.S)
	d_pressed := window.is_key_down(window.KEYS.D)
	e_pressed := window.is_key_down(window.KEYS.E)
	q_pressed := window.is_key_down(window.KEYS.Q)

	t := fly_camera_data.view.transform
	move_dir := lmath.V3_ZERO

	forward := lmath.get_Q_forward(t.rot)
	right := lmath.get_Q_right(t.rot)
	up := lmath.get_Q_up(t.rot)

	if w_pressed {
		move_dir += forward
	}

	if s_pressed {
		move_dir -= forward
	}

	if d_pressed {
		move_dir += right
	}

	if a_pressed {
		move_dir -= right
	}

	if e_pressed {
		move_dir += lmath.V3_UP
	}

	if q_pressed {
		move_dir -= lmath.V3_UP
	}

	if lmath.get_V_f32_length(move_dir) > 0.1 {

		fly_camera_data.smooth_move_dir += (move_dir * FLY_CAMERA_ACCELERATION) * dt
		if lmath.get_V_f32_length(fly_camera_data.smooth_move_dir) > 1 {
			fly_camera_data.smooth_move_dir = lmath.normalize_V(fly_camera_data.smooth_move_dir)
		}

	} else {

		l := lmath.get_V_length(fly_camera_data.smooth_move_dir)
		if l > 0.01 {

			deceleration: lmath.V3 = fly_camera_data.smooth_move_dir / l
			fly_camera_data.smooth_move_dir -= deceleration
		}
	}

	move := fly_camera_data.smooth_move_dir * FLY_CAMERA_MAX_SPEED
	fly_camera_data.view.transform.pos += move * dt

	// Rotation.
	look_delta := lmath.V2_ZERO
	look_delta += window.get_mouse_delta() * CAMERA_LOOK_SPEED
	fly_camera_data.look_euler.x += look_delta.y
	fly_camera_data.look_euler.y += look_delta.x

	if fly_camera_data.look_euler.x > 360 {
		fly_camera_data.look_euler.x -= 360
	}

	if fly_camera_data.look_euler.y > 360 {
		fly_camera_data.look_euler.y -= 360
	}

	look_euler := lmath.V3{fly_camera_data.look_euler.x, fly_camera_data.look_euler.y, 0}
	fly_camera_data.view.transform.rot = lmath.Q_from_euler(look_euler)
	// Apply.
	render.set_view(fly_camera_data.view)
}
