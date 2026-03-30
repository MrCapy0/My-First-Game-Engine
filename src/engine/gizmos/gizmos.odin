package gizmos

import "core:container/queue"
import "vendor:raylib"

DrawWireCubeData :: struct {
	pos:   raylib.Vector3,
	scale: raylib.Vector3,
	color: raylib.Color,
}

GizmoData :: union {
	DrawWireCubeData,
}

gizmos_draw_queue: queue.Queue(GizmoData)

init :: proc() {

	queue.init(&gizmos_draw_queue)
}

draw_wire_cube :: proc(pos: raylib.Vector3, scale: raylib.Vector3, color: raylib.Color) {

	gizmo: DrawWireCubeData = {
		pos   = pos,
		scale = scale,
		color = color,
	}

	queue.enqueue(&gizmos_draw_queue, gizmo)
}

draw :: proc() {

	l := queue.len(gizmos_draw_queue)
	for i := 0; i < l; i += 1 {

		gizmo := queue.dequeue(&gizmos_draw_queue)

		switch v in gizmo {
		case DrawWireCubeData:
			draw_wire_cube_now(v.pos, v.scale, v.color)
			break
		}
	}
}

end :: proc() {
	queue.destroy(&gizmos_draw_queue)
}

@(private)
draw_wire_cube_now :: #force_inline proc(
	pos: raylib.Vector3,
	scale: raylib.Vector3,
	color: raylib.Color,
) {

	// TODO: Disable when distant from camera.

	raylib.DrawCubeWires(pos, scale.x, scale.y, scale.z, color)

	// size := scale * {0.5, 0.5, 0.5}
	// left_front_down := pos + {-size.x, -size.y, size.z}
	// right_front_down := pos + {size.x, -size.y, size.z}
	// left_front_up := pos + {-size.x, size.y, size.z}
	// right_front_up := pos + {size.x, size.y, size.z}

	// left_back_down := pos + {-size.x, -size.y, -size.z}
	// right_back_down := pos + {size.x, -size.y, -size.z}
	// left_back_up := pos + {-size.x, size.y, -size.z}
	// right_back_up := pos + {size.x, size.y, -size.z}

	// raylib.DrawLine3D(left_back_down, right_back_down, color)
	// raylib.DrawLine3D(left_back_up, right_back_up, color)

	// raylib.DrawLine3D(left_front_down, right_back_down, color)
	// raylib.DrawLine3D(left_front_up, right_back_up, color)
}
