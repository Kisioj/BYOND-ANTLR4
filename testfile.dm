mob/player
	Login()
		usr << "BYOND version: [usr.client.byond_version], world.fps: [world.fps], world.tick_lag: [world.tick_lag], world.maxx: [world.maxx], world.maxy: [world.maxy]"
		world << "[src.name] has logged in"

		src.loc = locate(/turf/spawn_point/fire_academy)
		//src.Move(locate(/turf/spawn_point/fire_academy))
		src.icon = 'icons/naruto revolution/bases/base.dmi'
		src.true_icon = src.icon
		src.load_stats()
		new /obj/clothes/inuzuka_suit(src)

		src.verbs += /guild/verb/create_guild

		//src.name = input("What is your name?", "Name", src.name) as text
		//src.age = input("How old are you?", "Age") as num
		//src.favourite_color = input("Select your favourite color", "Favourite color") as color

		//src.draw_planes()
		//DayNight(False)
		client.screen += new/obj/lighting_plane
		client.screen += new/obj/hud/daynight

		//client.screen += new/obj/lighting_plane2
		overlays += /image/spotlight
		/*
		var/dict/d = new()
		d[4] = 5
		d[1] = 2
		d["4"] = "9"
		world << "A) [d.values()]"

		d.pop(1)
		d.pop(4)
		world << "B) [d.values()]"
		*/
		/*
		world << "list:"
		var/pylist/l = new()
		l.append(5)
		l.append(10)
		l.append(20)
		world << "l\[1]: [l[-1]], [l]"
		*/

		//world << "huehue: [d.values]"
		//var/list/L = list()
		//L["super"] = "alejaja"
		//world << "[L.Find("alejajaz")]"
		//var/matrix/M = matrix(list(0.2,0.05,0.05, 0.1,0.3,0.2, 0.1,0.1,0.4))
		//world << "[M]"
		//animate(src, transform = matrix()*2, alpha = 0, time = 5) //grow and fade

	Logout()
		world << "[src.name] has logged out"
		del(src)


mob/proc/DayNight(is_day)
	if(client)
		client.color = is_day ? null : list(0.2,0.05,0.05, 0.1,0.3,0.2, 0.1,0.1,0.4)
		//client.color = is_day ? null : list(0.8,0.05,0.05, 0.8,0.3,0.2, 0.8,0.1,0.4)
		//client.color = is_day ? null : list(0.1,0.025,0.025, 0.05,0.15,0.1, 0.05,0.05,0.2)

var
	list/glob_list = list(0.2,0.05,0.05, 0.1,0.3,0.2, 0.1,0.1,0.4)

atom
	New()
		..()
		color = glob_list //list(0.2,0.05,0.05, 0.1,0.3,0.2, 0.1,0.1,0.4)

mob
	verb
		change_color(x as num)
			glob_list[1] = x

obj/lighting_plane
	screen_loc = "1,1"
	plane = 2
	blend_mode = BLEND_MULTIPLY
	appearance_flags = PLANE_MASTER | NO_CLIENT_COLOR
	//color = list(0.2,0.05,0.05, 0.1,0.3,0.2, 0.1,0.1,0.4)
	//color = list(null,null,null,null,"#333f")
	//icon			= 'code/lib/weather.dmi'
	//icon_state		= "night"

	mouse_opacity = 0

obj/hud
	daynight
		icon			= 'code/lib/weather.dmi'
		icon_state		= "day"
		screen_loc		= "SOUTHWEST to NORTHEAST"
		plane			= 2
		mouse_opacity 	= 0
		blend_mode = BLEND_ADD



obj/lighting_plane2
	screen_loc = "1,1"
	plane = 3
	blend_mode = BLEND_MULTIPLY
	appearance_flags = PLANE_MASTER | NO_CLIENT_COLOR
	//color = list(5.555555555555556,-0.8333333333333334,	-0.2777777777777777, -1.1111111111111112,4.166666666666667,-1.9444444444444449, -1.111111111111111,-0.8333333333333336,3.0555555555555554)
	color = list(null,null,null,null,"#333f")
	//icon			= 'code/lib/weather.dmi'
	//icon_state		= "night"

	mouse_opacity = 0

image/spotlight
	plane = 2
	blend_mode = BLEND_ADD
	icon = 'icons/lightning.dmi'  // a 96x96 white circle
	pixel_x = -32
	pixel_y = -32


mob
	verb
		Pick_Color(newColor as color)

			var/ColorMatrix/c = new(newColor)

			animate(client, color = c.matrix, time = 10)

		Pick_ColorSatContBright(s as num, c as num, b as num)

			var/ColorMatrix/cm = new(s, c, b)

			animate(client, color = cm.matrix, time = 10)

		Pick_ColorPreset(newColor in list("Invert", "BGR", "Greyscale", "Sepia", "Black & White", "Polaroid", "GRB", "RBG", "BRG", "GBR", "Normal"))

			if(newColor == "Normal")
				animate(client, color = null, time = 10)

			else
				var/ColorMatrix/c = new(newColor)
				animate(client, color = c.matrix, time = 10)