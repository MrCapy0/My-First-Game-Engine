#version 410 core
out vec4 FragColor;

in vec3 ourColor;
in vec2 TexCoord;

// texture sampler
uniform sampler2D texture1;
uniform float mult = 1;
uniform vec3 color;

void main()
{
	FragColor = texture(texture1, TexCoord);
	FragColor.rgb *= color;
	FragColor.rgb *= mult;
}