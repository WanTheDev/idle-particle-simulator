particle_value=((global.cpp*(global.overdrive_on+1))*global.cash_mult) // bruh
global.cash+=((global.particles*particle_value)/room_speed)*global.speed_mult
if slowdown_delay>0 { slowdown_delay-- }
if slowdown_delay<=0 or global.speed_mult<global.power_minimum {
	slowdown_delay=0
	if global.speed_mult<global.power_minimum { global.speed_mult+=0.1 }
	else if global.speed_mult>global.power_minimum {
		global.speed_mult-=0.0001
		if global.speed_mult<global.power_minimum { global.speed_mult=global.power_minimum }
	}
}
if keyboard_check(vk_shift) and keyboard_check_pressed(ord("R")) { game_restart() }
if keyboard_check(vk_shift) and keyboard_check_pressed(ord("T")) { global.cash+=10000000 }
if keyboard_check(vk_shift) and keyboard_check_pressed(ord("Y")) { repeat(1000) { create_particle() } }
if cur_fps>=300 { cur_fps=1 avg_fps=fps
}else {
	cur_fps++
	avg_fps+=fps
}
cur_move=!cur_move