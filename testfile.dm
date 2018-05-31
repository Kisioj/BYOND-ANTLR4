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
		memory_skill = 3 //ile twarzy mo¿emy zapamiêtaæ do henge no jutsu
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