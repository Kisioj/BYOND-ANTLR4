proc/dupa()
	world << "Hello"
	return list(1, 2, "3")


mob/Login()
	for(var/mob/M as anything in dupa())
		world << M