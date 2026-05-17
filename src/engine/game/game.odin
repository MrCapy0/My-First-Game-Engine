package game

import player "mobs/player"

start :: proc() {

	player.start()
}

update :: proc(dt: f32) {

	player.update(dt)

	update_draw()
}

@(private)
update_draw :: proc() {

}
