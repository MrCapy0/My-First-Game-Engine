#version 420 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;
layout (location = 2) in vec2 aTexCoord;

out vec3 ourColor;
out vec2 TexCoord;

uniform mat4 transform;

layout (std140, binding = 2) uniform CameraData {
    mat4 perspective;
    mat4 translation;
	mat4 rotation;
} camera;

layout (location = 10) in mat4 instance_t;

void main()
{
	mat4 mvp = (camera.perspective * camera.rotation * camera.translation) * instance_t;
	gl_Position = mvp * vec4(aPos, 1.0);
	ourColor = aColor;
	TexCoord = vec2(aTexCoord.x, aTexCoord.y);
}