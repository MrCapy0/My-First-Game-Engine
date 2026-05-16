package lmath

import "core:math/linalg"

RAD_TO_DEG :: linalg.RAD_PER_DEG
DEG_TO_RAD :: linalg.DEG_PER_RAD

V2_f32 :: linalg.Vector2f32
V3_f32 :: linalg.Vector3f32
V4_f32 :: linalg.Vector4f32

V2 :: V2_f32
V3 :: V3_f32
V4 :: V4_f32

Q_f32 :: linalg.Quaternionf32

Q :: Q_f32

M2_f32 :: linalg.Matrix2f32
M3_f32 :: linalg.Matrix3f32
M4_f32 :: linalg.Matrix4f32

M2_f32_Identity :: linalg.MATRIX2F32_IDENTITY
M3_f32_Identity :: linalg.MATRIX3F32_IDENTITY
M4_f32_Identity :: linalg.MATRIX4F32_IDENTITY

M2_Identity :: M2_f32_Identity
M3_Identity :: M3_f32_Identity
M4_Identity :: M4_f32_Identity

M2 :: M2_f32
M3 :: M3_f32
M4 :: M4_f32

M4_f32_translate :: linalg.matrix4_translate_f32

M4_translate :: M4_f32_translate

translate :: proc {
	M4_translate,
}

M4_f32_from_Q_f32 :: linalg.matrix4_from_quaternion_f32

M4_from_Q :: M4_f32_from_Q_f32

M4_f32_perspective :: linalg.matrix4_perspective_f32

M4_perspective :: M4_f32_perspective

Q_f32_from_euler :: linalg.quaternion_from_pitch_yaw_roll

Q_from_euler :: Q_f32_from_euler
