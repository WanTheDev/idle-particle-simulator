var cur, dir, x_vib, y_vib, prev_cur;
var xoff=0
var yoff=0
var x_move=_x
if global.rgb {
	cur_clr++
	if cur_clr>255 { cur_clr=0 }
	var rgb_color=make_color_hsv(cur_clr,255,255)
	draw_set_color(rgb_color)
}
if !global.remove_bounds {
var max_x = _x+box_w-line_w
var max_y = _y+box_h-line_w
var min_x = _x-box_w+line_w
var min_y = _y-box_h+line_w
}else {
var max_x = room_width
var max_y = room_height
var min_x = 0
var min_y = 0
}
var vib = global.vibration_magnitude
if global.move_attraction {
	x_move=_x+sin(current_time/global.move_attraction_speed)*(box_w*0.75)	
}
var cur_size = global.bigger_particles ? 2 : 1
if global.pulse { cur_size=cur_size+sin(current_time/100)*cur_size/2 }
var grv_dir_v=0.05
var grv_dir_h=0
if global.gravity_change {
	grv_dir_v=lengthdir_y(0.05,(current_time/1000)*360)
	grv_dir_h=lengthdir_x(0.05,(current_time/1000)*360)
}
var p = global.particles_draw== 0 ? global.particles : global.particles_draw
if keyboard_check_pressed(ord("V")) {
	p = global.particles_draw
	if p==0 { p=5000 }
	else if p==5000 { p=2500 }
	else if p==2500 { p=1000 }
	else if p==1000 { p=500 }
	else if p==500 { p=100 }
	else if p==100 { p=50 }
	else if p==50 { p=10 }
	else { p = 0 }
	global.particles_draw=p
}

if cur_part<=p { cur_part+=p/120 }
if cur_part>p { cur_part=0 }
var cur_part_low = cur_part-p/120
draw_set_alpha(global.particle_alpha)

var y_move=_y
if global.mouse_attract {
	x_move=mouse_x
	y_move=mouse_y
}

x_move=x_move+irandom_range(-2,2)
y_move=y_move+irandom_range(-2,2)


var lmb = mouse_check_button(mb_left)
for(var i = 0; i < p; i++) {
	if i>=global.particles { break }
	cur=particles_array[i]
	if i<=cur_part and i>cur_part_low and (global.teleport or global.random_teleport) {
		if global.random_teleport {
			if global.remove_bounds {
				cur.x=irandom_range(0,room_width)
				cur.y=irandom_range(0,room_height)
			}else {
				cur.x=_x+irandom_range(-box_w,box_w)
				cur.y=_y+irandom_range(-box_h,box_h)
			}
		}else if global.teleport {
			cur.x=x_move
			cur.y=y_move
		}
	}
	if global.speed_mult!=0 {
		if global.focus_middle {
			dir = point_direction(cur.x,cur.y,x_move,y_move)*(global.mouse_repel and lmb ? -1 : 1)
		}else {
			dir=irandom(359)
		}
		if cur_move {
			cur.hsp=clamp(cur.hsp+lengthdir_x(global.particle_speed,dir),-global.particle_max_speed,global.particle_max_speed)
		}else {
			cur.vsp=clamp(cur.vsp+lengthdir_y(global.particle_speed,dir),-global.particle_max_speed,global.particle_max_speed)
		}
		if global.vibrate {
			x_vib = vib*choose(1,-1)
			y_vib = vib*choose(1,-1)
			cur.hsp+=x_vib
			cur.vsp+=y_vib
		}
		if global.grv {
			cur.vsp+=grv_dir_v*random_range(0.5,1.5)
			cur.hsp+=grv_dir_h*random_range(0.5,1.5)
		}
		if global.bounce  {
			if cur.x+cur.hsp > max_x or cur.x+cur.hsp < min_x { cur.hsp*=-0.5 }
			if cur.y+cur.vsp > max_y or cur.y+cur.vsp < min_y { cur.vsp*=-0.5 }
		}
		cur.x+=cur.hsp*global.speed_mult
		cur.y+=cur.vsp*global.speed_mult
		if global.bounce=false {
			if cur.x < min_x { cur.x=max_x }
			else if cur.x > max_x { cur.x=min_x }
			if cur.y < min_y { cur.y=max_y }
			else if cur.y > max_y { cur.y=min_y }
		}
	}else { cur.hsp=0 cur.vsp=0 }
	if cur.size!=cur_size { cur.size=lerp(cur.size,cur_size,0.05) }
	if global.colors and !global.rgb and !global.dis_color { draw_set_color(cur.clr) }
	if cur.x>min_x and cur.x<max_x and cur.y>min_y and cur.y<max_y {
		if global.dis_color { draw_set_color(make_color_rgb(221,point_distance(cur.x,cur.y,x_move,_y)/1000*255,56)) }
		draw_circle(cur.x,cur.y,cur.size,global.outline)
		if global.lines and i!=0 {
			prev_cur = particles_array[i-1]
			if prev_cur.x>min_x and prev_cur.x<max_x and prev_cur.y>min_y and prev_cur.y<max_y {
				draw_line_width(cur.x,cur.y,prev_cur.x,prev_cur.y,cur_size)
			}
		}
	}
}
draw_set_alpha(global.remove_bounds ? 0.1 : 1)
draw_set_color(c_white)
draw_rectangle_width(_x-box_w,_y-box_h,_x+box_w,_y+box_h,line_w)
draw_set_alpha(1)
var button_w=box_width
var button_sep=16
var button_x1 = _x+box_w-button_w
var button_x2 = _x+box_w
var button_y1 = _y+box_h+button_sep
var button_y2 = _y+box_h+button_sep+button_h
click_size=lerp(click_size,2,0.2)
draw_rectangle_width(button_x1,button_y1,button_x2,button_y2,line_w)
var hovering=false
if mouse_x>=button_x1 and mouse_x<=button_x2 and mouse_y>=button_y1 and mouse_y<=button_y2 {
	hovering=true
	if mouse_check_button(mb_left) { global.hold_click_timer++ }
	if mouse_check_button_pressed(mb_left) or (global.hold_click and global.hold_click_timer>=global.hold_click_speed) {
		if global.particles==0 {
			shake_text=10
		}else {
			click_size=1.75
			global.speed_mult=lerp(global.speed_mult,global.power_max,global.click_power*global.click_mult*0.005)
			slowdown_delay=global.power_deplete_time
		}
		global.hold_click_timer=0
	}
}else { global.hold_click_timer=0 }
draw_set_font(fGame)
draw_set_halign(fa_center)
draw_set_valign(fa_center)
var click_hover = click_size>1.99 ? "/  Click  \\" : "/   Click   \\"
draw_text_transformed(_x,_y+box_h+button_sep+button_h/2,hovering ? click_hover : "/ Click \\",click_size,click_size,0)
var text_sep_from_box=16+button_h+button_sep
var text_sep=32

draw_set_halign(fa_left)
draw_set_valign(fa_bottom)
draw_text(_x-box_w-line_w/2+1,room_height-9,"\\\\")
draw_text(_x+box_w-line_w-7,room_height-9,"//")
draw_text(_x-box_w*.85-4,room_height-9,"Shown Particles : " + (global.particles_draw==0 ? "ALL" : string(global.particles_draw)))
draw_text(_x+box_w*0.0275,room_height-9,"Click V To Toggle Shown Particles")
draw_set_valign(fa_top)
//draw_text(_x,9,"FPS_REAL : " + string(floor(fps_real)))
draw_text(_x-box_w-line_w/2+1,9,"//")
draw_text(_x-box_w*.85-4,9,"FPS : " + string(fps))
draw_text(_x+box_w/2,9,"AVG FPS : " + string(avg_fps/cur_fps))
draw_text(_x+box_w-line_w-7,9,"\\\\")

var upgrade_sep=16
var upgrade_h=button_h
var upgrade_w=480
var upgrade_x1 = button_x2-upgrade_w
var upgrade_x2 = button_x2
var upgrade_y1 = button_y2+upgrade_sep
var upgrade_y2 = button_y2+upgrade_sep+upgrade_h
var _cost, _y1, _y2, cur, owned_string;
var text_y_sep=16
var text_x_sep=16
var desc_y_sep=32
if type_writer_mode=0 {
	if type_writer<1 { type_writer+=type_writer_spd }
	if type_writer>1 { type_writer=1 }
}else {
	type_writer-=type_writer_spd
	if type_writer<=0 {
		type_writer=0
		cur_page+=type_writer_mode
		type_writer_mode=0
	}
}
var hovering_button=-1
var toggle_string;
for(var i = 0; i < 3; i++) {
	cur=ds_list_find_value(all_upgrades_list,i+cur_page*3)
	button_scale[i]=lerp(button_scale[i],1,0.2)
	if cur.toggle and cur.owned>0 { on_scale[i]=lerp(on_scale[i],1,0.2) }
	else { on_scale[i]=0 }
	_y1 = upgrade_y1+i*(upgrade_h+upgrade_sep)
	_y2 = upgrade_y2+i*(upgrade_h+upgrade_sep)
	draw_rectangle_width(upgrade_x1,_y1,upgrade_x2,_y2,line_w)
	draw_text(upgrade_x1+text_x_sep,_y1+text_y_sep,string_copy(cur._name,0,(string_length(cur._name)+1)*type_writer))
	draw_text(upgrade_x1+text_x_sep,_y1+text_y_sep+desc_y_sep,string_copy(cur.desc,0,(string_length(cur.desc)+1)*type_writer))
	draw_set_halign(fa_right)
	xoff=0
	yoff=0
	if button_shake[i]>0 { button_shake[i]-- xoff=irandom_range(-3,3) yoff=irandom_range(-3,3)}
	if cur.owned>=cur.owned_max and cur.owned_max!=0 {
		owned_string="Max"
	}else { owned_string=string(cur.owned) }
	_cost = "Owned : " + owned_string + " // $" +string(cur.cost)
	if cur.toggle=true and cur.owned>0 {
		var toggle_string = cur.turned_on ? "On" : "Off"
		draw_text_transformed(upgrade_x2-text_x_sep+xoff,_y2-text_y_sep*2+yoff,string_copy(toggle_string,0,(string_length(toggle_string)+1)*type_writer),button_scale[i]*on_scale[i],button_scale[i]*on_scale[i],0)	
		
	}
	draw_text_transformed(upgrade_x2-text_x_sep+xoff,_y1+text_y_sep+yoff,string_copy(_cost,0,(string_length(_cost)+1)*type_writer),button_scale[i],button_scale[i],0)
	draw_set_halign(fa_left)
	if mouse_x>=upgrade_x1 and mouse_x<=upgrade_x2 and mouse_y>=_y1 and mouse_y<=_y2 {
		if owned_string!="Max" {
			hovering_button=i
			if mouse_check_button_pressed(mb_left) or holding {
				if global.cash>=cur.cost {
					button_scale[i]=0.9
					cur.owned++
					if cur.owned>1 {
						if cur.turned_on==true { cur.action() }
					}else {
						cur.action()
					}
					add_upgrade(cur)
					global.cash-=cur.cost
					if cur.owned>=cur.owned_max and cur.owned_max!=0 { cur.cost=" - " }
					else { cur.cost*=cur.mult }
				}else { cant_afford=5 button_shake[i]=5 }
			}
		}else if mouse_check_button_pressed(mb_left) {
			button_shake[i]=5 
		}
		if mouse_check_button_pressed(mb_right) and cur.toggle=true {
			on_scale[i]=0.7
			
			cur.action(cur.turned_on)
			cur.turned_on = !cur.turned_on
		}
	}
}
if mouse_check_button_released(mb_left) { hold_timer=0 holding=false }
if hovering_button!=-1 {
	if hovering_button==hovering_old_button {
		if mouse_check_button(mb_left) {
			var cost_ = ds_list_find_value(all_upgrades_list,hovering_button+cur_page*3).cost
			if !is_string(cost_) {
				if global.cash>=ds_list_find_value(all_upgrades_list,hovering_button+cur_page*3).cost {
					hold_timer++
				}else { hold_timer=0 holding=false }
			}
			if hold_timer>=20 {
				holding=true	
			}
		}else { holding=false }
	}else { 
		hold_timer=0
		holding=false
		hovering_old_button=hovering_button
	}
}
var _ystats = upgrade_y1-(upgrade_h+upgrade_sep)+text_sep_from_box
var _xstats = _x-box_w
var page_h = upgrade_h/2-8
var page_mid = (_xstats+(upgrade_x1-15))/2
lerp_cash=lerp(lerp_cash,global.cash,0.2)
lerp_power=lerp(lerp_power,global.speed_mult*100,0.1)
if global.speed_mult==1 { lerp_power=100 }
if global.speed_mult==0 { lerp_power=0 }
if abs(lerp_cash-global.cash)<0.01 { lerp_cash=global.cash }
draw_text(_xstats,_ystats,"Particles : " + string(global.particles))
xoff=0
yoff=0
if cant_afford>0 { cant_afford-- xoff=irandom_range(-4,4) yoff=irandom_range(-4,4) } 
draw_text(_xstats+xoff,_ystats+text_sep+yoff,"Cash : $" + string(lerp_cash))
draw_text(_xstats,_ystats+text_sep+text_sep,"Power : " + string_format(lerp_power,2,2) + "%")
draw_text(_xstats,_ystats+text_sep+text_sep+text_sep,"Click Power : " + string(global.click_power*global.click_mult/2))

if particle_value!=old_value {
	if old_value<particle_value { particle_value_scale=1.2 }
	old_value = particle_value
}else { particle_value_scale=lerp(particle_value_scale,1,0.15) }
var text_v = "Particle Value : $" + string(particle_value)
var text_w = string_width(text_v)
var text_h = string_height(text_v)

draw_text_transformed(_xstats-text_w/2*(particle_value_scale-1),_ystats-text_h/2*(particle_value_scale-1)+text_sep+text_sep+text_sep+text_sep,text_v,particle_value_scale,particle_value_scale,0)
draw_text(_xstats,_ystats+text_sep+text_sep+text_sep+text_sep+text_sep,"Power time : " + string_format(slowdown_delay/room_speed,1,2) + "s")
var over_drive_info = "N/A"
if global.overdrive {
	if lerp_power>=100 {
		global.overdrive_on=true
		over_drive_info="On"	
	}else { global.overdrive_on=false over_drive_info="Off" }
}
draw_text(_xstats,_ystats+text_sep+text_sep+text_sep+text_sep+text_sep+text_sep,"Over-drive : " + over_drive_info)
draw_rectangle_width(_xstats,_y1,upgrade_x1-15,_y1+page_h,line_w)
draw_rectangle_width(_xstats,_y1+page_h+16,upgrade_x1-15,_y1+page_h+16+page_h,line_w)
draw_set_halign(fa_center)
draw_set_valign(fa_center)
if global.particles==0 or tutorial_mode!=3 {
	xoff=0
	yoff=0
	var _size, _txt;
	if tutorial_mode==0 {
		_size=1.5
		_txt = "!!! BUY SOME PARTICLES BEFORE CLICKING !!!"
		if global.particles>0 {
			if text_typewriter>0 {
				text_typewriter-=type_writer_spd/3
			}else { tutorial_mode=1 }
		}
	}else if tutorial_mode>0 {
		_size=1
		_txt = "Each particle makes $" + string(particle_value) + " per second at 100% power\n(less power = less $ per particle)\nby clicking you slowly increase the power\nwhenever you stop clicking, the power goes down\nreach 50% power (by clicking) to remove this text\n\nalso, you can toggle off any cosmetic upgrade by right clicking it,\nonly visuals will change while the particle value will stay the same!"
		if tutorial_mode==1 { 
			if text_typewriter<1 {
				text_typewriter+=type_writer_spd/10
			}
			if text_typewriter>1 {
				text_typewriter=1
			}
			if global.speed_mult>=0.5 { tutorial_mode=2 }
		}else {
			if text_typewriter>0 {
				text_typewriter-=type_writer_spd/3
			}else { tutorial_mode=3 }
		}
	}
	if shake_text>0 {
		shake_text--
		xoff=irandom_range(-5,5)
		yoff=irandom_range(-5,5)
	}
	draw_text_transformed(_x+xoff,_y+yoff,string_copy(_txt,0,(string_length(_txt)+1)*text_typewriter),_size,_size,0)	
}
var last_page = ds_list_size(all_upgrades_list)/3-1
if cur_page==last_page {
	if next_page_typewriter>0 { next_page_typewriter-=type_writer_spd }
	if next_page_typewriter<0 { next_page_typewriter=0 }
}else {
	if next_page_typewriter<1 { next_page_typewriter+=type_writer_spd }
	if next_page_typewriter>1 { next_page_typewriter=1 }
}
if cur_page==0 {
	if prev_page_typewriter>0 { prev_page_typewriter-=type_writer_spd }
	if prev_page_typewriter<0 { prev_page_typewriter=0 }
}else {
	if prev_page_typewriter<1 { prev_page_typewriter+=type_writer_spd }
	if prev_page_typewriter>1 { prev_page_typewriter=1 }
}
draw_text(page_mid,_y1+page_h/2,string_copy(next_page_text,0,string_length(next_page_text)*next_page_typewriter))
draw_text(page_mid,_y1+page_h*1.5+16,string_copy(prev_page_text,0,string_length(prev_page_text)*prev_page_typewriter))
if mouse_check_button_pressed(mb_left) {
	if mouse_x>_xstats and mouse_x<upgrade_x1-15 {
		if mouse_y>_y1 and mouse_y<_y1+page_h and cur_page<last_page{
			type_writer_mode=1
		}else if mouse_y>_y1+page_h+16 and mouse_y<_y1+page_h+16+page_h and cur_page>0 {
			type_writer_mode=-1
		}
	}
}
draw_set_halign(fa_left)