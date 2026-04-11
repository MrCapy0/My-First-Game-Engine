package render

import console "../console"
import image "core:image"
import png "core:image/png"
import os "core:os"
import gl "vendor:OpenGL"

ColorModes :: enum {
	RGBA,
}

Texture :: struct {
	id:     u32,
	width:  u32,
	height: u32,
	color:  ColorModes,
}

TextureInternal :: struct {
	texture: u32,
}

loaded_textures: map[u32]TextureInternal

load_texture :: proc(path: string) -> Texture {

	if !os.exists(path) {

		console.error_fmt("Image file does not exist on %s!", path)
		return {}
	}

	img, error := png.load(path)
	if error != image.General_Image_Error.None {

		console.error_fmt("Can't read image file on %s", path)
		return {}
	}

	texture_id: u32
	gl.GenTextures(1, &texture_id)
	gl.BindTexture(gl.TEXTURE_2D, texture_id)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
	gl.TexImage2D(
		gl.TEXTURE_2D,
		0,
		gl.RGBA,
		i32(img.width),
		i32(img.height),
		0,
		gl.RGBA,
		gl.UNSIGNED_BYTE,
		raw_data(img.pixels.buf),
	)

	gl.GenerateMipmap(gl.TEXTURE_2D)

	// Remove active texture.
	gl.BindTexture(gl.TEXTURE_2D, 0)

	new_texture: Texture = {
		id     = u32(len(loaded_textures)),
		width  = u32(img.width),
		height = u32(img.height),
	}

	new_texture_internal: TextureInternal = {
		texture = texture_id,
	}

	loaded_textures[new_texture.id] = new_texture_internal
    
	return new_texture
}
