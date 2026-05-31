package lmath

import "core:math/linalg"

DEG_TO_RAD :: linalg.RAD_PER_DEG
RAD_TO_DEG :: linalg.DEG_PER_RAD

V2_f32 :: linalg.Vector2f32
V3_f32 :: linalg.Vector3f32
V4_f32 :: linalg.Vector4f32

V2 :: V2_f32
V3 :: V3_f32
V4 :: V4_f32

V2_f32_ZERO: V2 : {0, 0}
V3_f32_ZERO: V3 : {0, 0, 0}
V4_f32_ZERO: V4 : {0, 0, 0, 0}

V3_f32_RIGHT: V3_f32 : {1, 0, 0}
V3_f32_UP: V3_f32 : {0, 1, 0}
V3_f32_FORWARD: V3_f32 : {0, 0, 1}

V2_ZERO :: V2_f32_ZERO
V3_ZERO :: V3_f32_ZERO
V4_ZERO :: V4_f32_ZERO

V3_RIGHT :: V3_f32_RIGHT
V3_UP :: V3_f32_UP
V3_FORWARD :: V3_f32_FORWARD

Q_f32 :: linalg.Quaternionf32
Q_f32_Identity :: linalg.QUATERNIONF32_IDENTITY

Q :: Q_f32
Q_Identity :: Q_f32_Identity

M2_f32_Identity :: linalg.MATRIX2F32_IDENTITY
M3_f32_Identity :: linalg.MATRIX3F32_IDENTITY
M4_f32_Identity :: linalg.MATRIX4F32_IDENTITY

M2_f32 :: linalg.Matrix2f32
M3_f32 :: linalg.Matrix3f32
M4_f32 :: linalg.Matrix4f32

M2_Identity :: M2_f32_Identity
M3_Identity :: M3_f32_Identity
M4_Identity :: M4_f32_Identity

M2 :: M2_f32
M3 :: M3_f32
M4 :: M4_f32

get_V_f32_length :: linalg.vector_length
normalize_V_f32 :: linalg.vector_normalize

get_V_length :: get_V_f32_length

normalize_V :: normalize_V_f32
lerp_V :: linalg.lerp

M4_f32_translate :: linalg.matrix4_translate_f32
M4_translate :: M4_f32_translate

translate :: proc {
	M4_translate,
}

M4_f32_perspective :: linalg.matrix4_perspective_f32
M4_f32_inverse :: linalg.matrix4_inverse_f32


M4_perspective :: M4_f32_perspective
M4_inverse :: M4_f32_inverse

angle_between_V3_and_V3 :: angle_between_V3_f32_and_V3_f32
angle_between_V3_f32_and_V3_f32 :: linalg.vector_angle_between


@(require_results)
euler_xyz_f32_to_Q_f32 :: proc(x: f32, y: f32, z: f32) -> Q {
	return linalg.quaternion_from_pitch_yaw_roll_f32(
		x * DEG_TO_RAD,
		y * DEG_TO_RAD,
		z * DEG_TO_RAD,
	)
}

@(require_results)
euler_V3_f32_to_Q_f32 :: #force_inline proc(v: V3_f32) -> Q_f32 {
	return euler_xyz_f32_to_Q_f32(v.x, v.y, v.z)
}

@(require_results)
get_Q_f32_forward :: #force_inline proc(q: Q) -> V3_f32 {
	return get_Q_direction(q, V3_FORWARD)
}

@(require_results)
get_Q_f32_right :: #force_inline proc(q: Q) -> V3_f32 {
	return get_Q_direction(q, V3_RIGHT)
}

@(require_results)
get_Q_f32_up :: #force_inline proc(q: Q) -> V3_f32 {
	return get_Q_direction(q, V3_UP)
}

euler_to_Q :: proc {
	euler_xyz_f32_to_Q_f32,
	euler_V3_f32_to_Q_f32,
}

Q_f32_lerp :: linalg.quaternion_nlerp_f32
Q_f32_slerp :: linalg.quaternion_slerp_f32
Q_f32_to_M4_f32 :: linalg.matrix4_from_quaternion_f32
Q_f32_direction :: linalg.quaternion128_mul_vector3
get_Q_direction :: Q_f32_direction
get_Q_forward :: get_Q_f32_forward
get_Q_right :: get_Q_f32_right
get_Q_up :: get_Q_f32_up
Q_lerp :: Q_f32_lerp
Q_slerp :: Q_f32_slerp
Q_to_M4 :: Q_f32_to_M4_f32

@(require_results)
angle_between_Q_f32_and_Q_f32 :: proc(a: Q, b: Q) -> f32 {
	return linalg.angle_between(a, b) * linalg.RAD_PER_DEG
}

angle_between :: proc {
	angle_between_Q_f32_and_Q_f32,
}
