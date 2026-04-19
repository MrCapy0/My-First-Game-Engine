#version 410 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;
layout (location = 2) in vec2 aTexCoord;

out vec3 ourColor;
out vec2 TexCoord;

uniform mat4 transform;

layout (std140) uniform CameraData {
    mat4 perspective;
    mat4 translation;
	mat4 rotation;
} camera;

void main()
{
	mat4 view = camera.rotation * camera.translation;
	mat4 mvp = camera.perspective * view * transform;
	gl_Position = mvp * vec4(aPos, 1.0);
	ourColor = aColor;
	TexCoord = vec2(aTexCoord.x, aTexCoord.y);
}