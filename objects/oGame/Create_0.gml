button_h=115
box_width=room_width*0.9
var dis_from_edge = (room_width-box_width)/2
box_height=button_h+dis_from_edge*2
box_w=box_width/2
box_h=box_height/2
line_w=5
for(var i = 0; i < 3; i++) {
	button_scale[i]=1
	button_shake[i]=0
	on_scale[i]=1
}
_x = room_width/2
_y = box_h+dis_from_edge
particles_array = array_create(0) // Storing all particles in an array to access them later
all_upgrades_list = ds_list_create() // Storing all upgrades in a list to read out the price/name/function from
cant_afford=0 // Variable coresponding to the shake of the "BUY PARTICLES BEFORE CLICKING" text
function particle_action() {
	with(oGame) {
		create_particle()
	}
}

#region toggle-able upgrades 

function power_minimum_action(_toggle=false) { global.power_minimum=_toggle ? 0 : owned*0.1 }
function particle_speed_action(_toggle=false) { global.particle_speed=_toggle ? 0.1 : owned*0.1 }
function power_max_action(_toggle=false) { global.power_max=_toggle ? 1 : 1+owned*0.05 }
function particle_max_speed_action(_toggle=false) { global.particle_max_speed=_toggle ? 10 : 10+owned*1.5 }
function attraction_point_speed_action(_toggle=false) { global.move_attraction_speed=_toggle ? global.move_attraction_speed_default : global.move_attraction_speed_default-owned*230 }
function vib_mag_action(_toggle=false) { global.vibration_magnitude=_toggle ? 0.25 : 0.25+owned*0.1 }

function particle_attraction_action() { global.focus_middle=!global.focus_middle }
function moving_attraction_point_action() { global.move_attraction=!global.move_attraction }
function bounce_action() { global.bounce=!global.bounce }
function colors_action() { global.colors=!global.colors }
function rgb_action() { global.rgb=!global.rgb }
function vibrations_action() { global.vibrate=!global.vibrate }
function big_action() { global.bigger_particles=!global.bigger_particles }
function gravity_action() { global.grv=!global.grv }
function pulse_action() { global.pulse=!global.pulse }
function translucent_action() { global.particle_alpha=global.particle_alpha==0.33 ? 1 : 0.33}
function gravity_change_action() { global.gravity_change=!global.gravity_change }
function line_action() { global.lines=!global.lines }
function teleport_action() { global.teleport=!global.teleport }
function distance_coloring_action() { global.dis_color=!global.dis_color }
function outline_action() { global.outline=!global.outline }
function mouse_attract_action() { global.mouse_attract=!global.mouse_attract }
function mouse_repel_action() { global.mouse_repel=!global.mouse_repel }
function random_teleport_action() { global.random_teleport=!global.random_teleport }

function remove_bounds_action() {
	global.remove_bounds=!global.remove_bounds
	if global.remove_bounds==false {
		var cur;
		for(var i = 0; i < global.particles; i++) {
			cur = other.particles_array[i]
			cur.x=irandom_range(other._x-other.box_w*0.9,other._x+other.box_w*0.9)
			cur.y=irandom_range(other._y-other.box_h*0.9,other._y+other.box_h*0.9)
		}
	}
}

#endregion

function stronger_click_action() {global.click_power+=1}
function valuable_particle_action() { global.cpp+=0.02 }
function overdrive_action() { global.overdrive=true }
function power_deplete_action() { global.power_deplete_time+=30 }
function hold_click_action() { global.hold_click=true }
function click_mult_action() { global.click_mult++ }
function hold_speed_action() { global.hold_click_speed-=global.hold_click_incr }

function upgrade_create(name_,_description,_cost,_action,_mult,_max=0,_toggle=false,_cash_add_mult=0) constructor {
	_name=name_
	desc=_description
	cost=_cost
	action=_action
	mult=_mult
	owned=0
	added_upgrades=0
	owned_max=_max
	toggle=_toggle
	turned_on=true
	cash_add_mult=_cash_add_mult
}

function add_upgrade(_struct) {
	with(_struct) {
		//show_message(string(owned) + " " + string(added_upgrades))
		while(owned>added_upgrades) {
			global.cash_mult+=cash_add_mult
			//show_message("added : " + string(cash_add_mult))
			added_upgrades++	
		}
	}
}

ds_list_add(all_upgrades_list,
	new upgrade_create("Particle","Add another particle to your collection",1.0452381,particle_action,1.005),
	new upgrade_create("Valuable Particle","Makes particles more valuable",10,valuable_particle_action,2.78,10),
	new upgrade_create("Stronger Click","Makes your click affect the generator more",15,stronger_click_action,1.18,7),
	
	new upgrade_create("Power deplete","Power depletion takes longer to start\nafter you stop clicking",25,power_deplete_action,4,8),
	new upgrade_create("Hold Click","You don't have to click anymore\nyou can just hold!",35,hold_click_action,1,1),
	new upgrade_create("Hold Speed","Increases the hold clicking speed",50,hold_speed_action,2,10),
	
	new upgrade_create("Click Multiplier","Click power is multiplied by the\namount of this upgrade owned plus 1",75,click_mult_action,4,5),
	new upgrade_create("Colors","Colors the particle",100,colors_action,1,1,true,0.25),
	new upgrade_create("Particle Attraction","Attracts particles to the middle",200,particle_attraction_action,1,1,true,0.25),
	
	new upgrade_create("Bigger particles","Makes particles a little bit bigger",400,big_action,1,1,true,0.5),
	new upgrade_create("Particle Acceleration","Increases the acceleration of the particles",500,particle_speed_action,1.25,25,true,0.1),
	new upgrade_create("Translucent Particles","Makes the particles translucent",1000,translucent_action,1,1,true,0.5),
	
	new upgrade_create("Power Minimum","Minimum power increases by 10",1000,power_minimum_action,2,10,true),
	new upgrade_create("Overdrive","Increase the particle value by 100%\nwhenever you hit >100% Power",1500,overdrive_action,1,1),
	new upgrade_create("Power Max","Increases the maximum power by 5\n(makes it alot easier to reach high power)",2000,power_max_action,1,5,true),
	
	new upgrade_create("Particle Max Speed","Increases the maximum speed\nmaking them more valuable",1250,particle_max_speed_action,2,10,true,0.1),
	new upgrade_create("Wrapping edges","Instead of the particles bouncing\nthey teleport now when they hit the edge",2500,bounce_action,1,1,true,0.33),
	new upgrade_create("RGB","Makes all the particles the same color\nbut it also cycles through colors",5000,rgb_action,1,1,true,0.2),
	
	new upgrade_create("Gravity","Particles are constantly pushed downwards",10000,gravity_action,1,1,true,0.25),
	new upgrade_create("Moving attraction point","Moves the attraction point constantly",20000,moving_attraction_point_action,1,1,true,0.25),
	new upgrade_create("Attraction point speed","Increases the speed of the\nmoving attraction point",30000,attraction_point_speed_action,2,3,true,0.25),
	
	new upgrade_create("Outlined Particles","Makes the particles only outlines\n(Bigger particles make it look better)",40000,outline_action,1,1,true,0.2),
	new upgrade_create("Mouse Attraction","Attraction point is always ontop of the mouse!",50000,mouse_attract_action,1,1,true,0.33),
	new upgrade_create("Mouse Repel","Left click to repel particles\nfrom the attraction point!",60000,mouse_repel_action,1,1,true,0.5),
	
	new upgrade_create("Vibrations","Makes all the particles vibrate",70000,vibrations_action,1,1,true,0.33),
	new upgrade_create("Vibration Magnitude","Makes the vibrations more aggressive",80000,vib_mag_action,1.25,10,true,0.25),
	new upgrade_create("Particles Teleport","Particles constantly teleport\nto the attraction point",90000,teleport_action,1,1,true,3),
	
	new upgrade_create("Distance Coloring","Colors of particles changes depending on how\nfar away they are from the attraction point",100000,distance_coloring_action,1,1,true,0.33),
	new upgrade_create("Gravity Change","Gravity direction changes constantly",110000,gravity_change_action,1,1,true,0.5),
	new upgrade_create("Pulsating Particles","Particles pulse in size",120000,pulse_action,1,1,true,0.25),
	
	new upgrade_create("Remove bounds","Removes the box that traps the particles...",130000,remove_bounds_action,1,1,true,1),
	new upgrade_create("Particle brain waves","Particle comunicate to each other\nvia brain waves...?",140000,line_action,1,1,true,1.25),
	new upgrade_create("Random Teleport","Particles now constantly teleport\nto a random spot!",150000,random_teleport_action,1,1,true,2)
	
	
	
)
cur_part=0
function particle_struct_create(x_,y_,clr_) constructor {
	x=x_
	y=y_
	clr=clr_
	hsp=0
	vsp=0
	size=5
}
function draw_rectangle_width(x1,y1,x2,y2,width) {
	x2--
	draw_line_width(x1+width/2,y1,x2+width/2,y1,width)
	draw_line_width(x1,y1-width/2,x1,y2+width/2,width)
	draw_line_width(x2+width/2,y2,x1+width/2,y2,width)
	draw_line_width(x2,y2-width/2,x2,y1+width/2,width)
}
function create_particle() {
	particles_array[global.particles] = new particle_struct_create(irandom_range(_x-box_w*0.9,_x+box_w*0.9),irandom_range(_y-box_h*0.9,_y+box_h*0.9),make_color_hsv(irandom(255),255,255))
	global.particles++
}
cur_move=0
cur_clr=0

global.mouse_repel=false
global.mouse_attract=false
global.random_teleport=false

global.outline=false
global.dis_color=false
global.teleport=false

global.particles_draw=0
global.cash_mult=1
global.bigger_particles=false
global.remove_bounds=false
global.gravity_change=false
global.lines=false
global.particle_alpha=1
global.pulse=false
global.grv=false
global.vibration_magnitude=0.25
global.hold_click=false // false
global.click_mult=1
global.hold_click_speed=1*room_speed // 30
global.hold_click_incr=global.hold_click_speed/(10+0.5)
global.hold_click_timer=0
global.move_attraction_speed=2500
global.move_attraction_speed_default=global.move_attraction_speed
global.vibrate=false
global.rgb=false
global.colors=false
global.power_deplete_time=59 // setting this to 59 and not 60 so power time in the ui doesn't flash with a 1 everytime u click, it's annoying looking
global.bounce=true
global.move_attraction=false
global.focus_middle=false
global.particle_max_speed=10
global.particles=0
next_page_text="Next Page"
prev_page_text="Prev Page"
next_page_typewriter=1
prev_page_typewriter=0
type_writer=0
type_writer_mode=0
type_writer_spd=1/20
cur_page=0
global.power_max=1
global.power_minimum=0
global.click_power=3
global.overdrive_on=false
global.overdrive=false
global.particle_speed=0.1
global.cash=6
global.cpp=0.03 //Cash per particle
global.speed_mult=0
slowdown_delay=10
lerp_cash=0
lerp_power=0
hovering_old_button=-1
holding=false
shake_text=0
text_typewriter=1
tutorial_mode=0
click_size=2
avg_fps=0
cur_fps=0
particle_value=global.cpp
randomize()

old_value=global.cpp
particle_value_scale=1