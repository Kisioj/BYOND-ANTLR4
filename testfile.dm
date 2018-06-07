mob
	var
		hp = 100
		max_hp = 100
		chakra = 50
		max_chakra = 50

		true_tai = 10
		tai_exp = 0
		tai_max_exp = 100

		true_nin = 10
		nin_exp = 0
		nin_max_exp = 100

		true_gen = 10
		gen_exp = 0
		gen_max_exp = 100

		tmp
			tai
			nin
			gen

		rank = ACADEMY_STUDENT

		obj/hairstyle/hairstyle = None
		list/clothes = new/list()

		in_henge = False
		list/face_memory = new/list() //TODO: lista bedzie miala limit max 10, na poczatku max 1, trenowanie pamieci bedzie odbywalo sie przez granie w memory zakupione u handlarza
		memory_skill = 3 //ile twarzy mo�emy zapami�ta� do henge no jutsu
		true_icon = None

		resting = False
		camera_locked = False
		on_water = False
		can_attack = True

		age = 18
		favourite_color = None
		water_walking = False

		yen = 100000
		guild = None

		tmp
			can_say_time = 0
			deque/limited_deque/say_times = None

	__init__()
		. = ..()
		src.say_times = new/deque/limited_deque(limit=5)

	/*
	__move__(loc)
		world << "loc: [loc]"
		//if(resting)
		//	return 0

		return ..()
	*/
	proc
		load_stats()
			src.tai = src.true_tai
			src.nin = src.true_nin
			src.gen = src.true_gen

		add_overlay(var/obj/obj, overlay_layer)
			var/initial_layer = obj.layer
			obj.layer = overlay_layer
			src.overlays += obj
			obj.layer = initial_layer

		update_overlays()
			src.overlays = None

			var
				show_hair = True
				list/worn_clothes = new/list()

			for (var/obj/clothes/obj in src.clothes)
				if (obj.worn)
					worn_clothes += obj
					if (obj.hide_hair_when_worn)
						show_hair = False

			if (show_hair && src.hairstyle)
				src.add_overlay(src.hairstyle, HAIR_LAYER)

			for (var/obj/clothes/obj in worn_clothes)
				src.add_overlay(obj, CLOTHES_LAYER)


	proc
		is_spamming_say()
			return src.say_times.is_full() && (src.say_times.last() - src.say_times.first() < 30)

	verb
		say(msg as text)
			var
				time = world.time

			if (time < usr.can_say_time)
				usr << {"You cannot say anything for [round((usr.can_say_time - time)/10)] more seconds. Following message won't be displayed: "[msg]""}
				return

			msg = html_encode(msg)

			if (len(msg) > 240)
				usr << {"Your message is too long, and will be shortened to 240 characters, original message: "[msg]""}
				msg = copytext(msg, 1, 240) + "..."

			usr.say_times.append(time)
			view() << {"<b>[usr]</b>: [msg]"}

			if (usr.is_spamming_say())
				usr << "SPAM DETECTION: You won't be able to say anything for 3 minutes"
				usr.can_say_time = time + 1800
/*

proc/get_speed_delay(n)
	if(n != 0)
		return (world.icon_size * world.tick_lag) / n
	else
		return (world.icon_size * world.tick_lag) / 1


atom/movable
	appearance_flags = LONG_GLIDE

	var/speed = 3
	var/tmp/move_time = 0
	var/tmp/transferring = 0

	Move(new_loc, dir)
		//world << "new_loc: [new_loc], dir: [dir]"
		if(!src.loc) return ..(new_loc, dir)

		if(world.time < src.move_time) return 0

		if(transferring) return 0

		. = ..(new_loc, dir)
		//world << ". is [.]"
		if(.)
			src.move_time = world.time + get_speed_delay(src.speed)
			src.glide_size = speed
			world << "glide_size: [glide_size], speed_delay: [get_speed_delay(src.speed)]"


mob
	var/w,a,s,d = 0

	proc/move_loop()
		if(!step(src, (!w && s && SOUTH) | (!s && w && NORTH) | (!d && a && WEST) | (!a && d && EAST)))
			if(!step(src, (s && SOUTH) | (w && NORTH)))
				step(src, (a && WEST) | (d && EAST))
		spawn(world.tick_lag) move_loop()

	verb/keydown(k as text)
		set hidden = 1
		set instant = 1
		if(k == "w") w = 1
		if(k == "a") a = 1
		if(k == "s") s = 1
		if(k == "d") d = 1

	verb/keyup(k as text)
		set hidden = 1
		set instant = 1
		if(k == "w") w = 0
		if(k == "a") a = 0
		if(k == "s") s = 0
		if(k == "d") d = 0



client
	New()
		..()
		//fps = 60
		winset(src, "North", "parent=macro;name=North;command=keydown+w")
		winset(src, "North+up", "parent=macro;name=North+up;command=keyup+w")
		winset(src, "West", "parent=macro;name=West;command=keydown+a")
		winset(src, "West+up", "parent=macro;name=West+up;command=keyup+a")
		winset(src, "South", "parent=macro;name=South;command=keydown+s")
		winset(src, "South+up", "parent=macro;name=South+up;command=keyup+s")
		winset(src, "East", "parent=macro;name=East;command=keydown+d")
		winset(src, "East+up", "parent=macro;name=East+up;command=keyup+d")
		src.mob.move_loop()

*/
	//Move(loc, dir)
	//	src.mob.Move(loc, dir)



	//North()
	//	src.mob.Move(src.mob, NORTH)