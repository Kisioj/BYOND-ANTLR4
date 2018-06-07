guild_member_info
	var
		id = None
		name = None
		ninja_rank = None
		guild_rank = None
		join_date = None

guild_rank_permissions
	var
		drop_furniture_in_guild_house = False
		pick_up_furniture_in_guild_house = False


guild
	var
		name = None
		members_limit = 3  //max 30, b�dzie mo�na dokupywa� limit u Guild Mastera
		guild_house = None  //numer domku gildii
		guild_master = None


	verb
		create_guild()
			//tylko od chuunina wzwyz moga zakladac gildie
			set name = "Create Guild"
			set category = "Guild"
			if (usr.guild)
				usr << "You are already in a guild"
				return

			usr.guild = input("What name you want for your guild?", "Create Guild") as text
			usr << {"You created guild named "[usr.guild]""}
			usr.verbs -= /guild/verb/create_guild
			usr.verbs += /guild/verb/invite
			usr.verbs += /guild/verb/kick
			usr.verbs += /guild/verb/leave

		guild_info()
			// wypisz informacje o mistrzu gildi i o czlonkach gildii
			// o tym czy jest guild house
			// historia bitew gildii

		create_rank()
			// tutaj bedzie mozna tworzyc rangi w gildii i nadawac im uprawnienia, a potem rangi przypisywac graczom

		edit_rank()
			//

		guild_log()
			// log gildii, ostatnie 1000 wydarze� w formie htmlowej

		promote_member()
			set name = "Promote member"
			set category = ""

		invite()
			set name = "Invite"
			set category = "Guild"

		kick()
			set name = "Kick"
			set category = "Guild"

		leave()
			set name = "Leave"
			set category = "Guild"
			usr << {"You leave guild "[usr.guild]""}
			usr.guild = None
			usr.verbs += /guild/verb/create_guild
			usr.verbs -= /guild/verb/invite
			usr.verbs -= /guild/verb/kick
			usr.verbs -= /guild/verb/leave