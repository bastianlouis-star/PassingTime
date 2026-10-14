class_name Data
extends RefCounted
# All content. An "action" is something you do at a hotspot. Actions can
#  - require flags (things learned/found earlier)       -> req
#  - give flags (discoveries that open new actions)      -> give
# Era n+1 is reached through the one hotspot action marked "exit".

const DAY := 1.0 / 365.25
const HOUR := DAY / 24.0
const MIN := HOUR / 60.0

static func A(id: String, nm: String, dur: String, years: float, sec: float, decay: float, vis: String, line: String, o: Dictionary = {}) -> Dictionary:
	var d := {"id": id, "name": nm, "dur": dur, "years": years, "sec": sec, "decay": decay, "vis": vis, "line": line,
		"req": [], "needs": [], "soft": [], "lock_msgs": {}, "give": [], "exhausts": [], "min_years": 0.0, "hide": [], "max_uses": 0, "sec_range": [], "once": false, "search": false, "lock": "", "exit": false}
	d.merge(o, true)
	return d

static func H(id: String, nm: String, x: float, acts: Array, show: Array = []) -> Dictionary:
	return {"id": id, "name": nm, "x": x, "acts": acts, "show": show}

# A line of philosophy shown with the "NEW" message the first time you try each action.
const QUOTES := {
	"write2": "The middle of anything is where faith is tested.",
	"write3": "Finishing is the last form of letting go.",
	"piano2": "Repetition is how the hands learn what the heart already knows.",
	"piano3": "To master a song is to finally stop hearing the notes.",
	"wait_apples": "The tree does not hurry, and still every fruit arrives.",
	"search_kitchen": "The things that feed us are rarely only the food.",
	"sill": "Even a view leaves things behind, if you look long enough.",
	"window_all": "What we watch without change eventually watches us back.",
	"read_all": "A finished library is only a closed door with a nicer smell.",
	"game_all": "To win everything is to find the prize was the playing.",
	"tv_back": "We circle the shows we mean to watch, and call it hope.",
	"movie_all": "Stories end; the wanting for one never quite does.",
	"clock_all": "Stare long enough at anything and its name falls off.",
	"chess_all": "Every possibility, once played, becomes just another habit.",
	"read_novel": "Every book is a door someone else left open.",
	"search_shelf": "What we have stopped looking at, we have already lost.",
	"read_almanac": "Patience is only hope that has learned to sit still.",
	"record": "Music is time you can hold for three minutes.",
	"record_all": "To listen to everything is to finally hear nothing in particular.",
	"sleeves": "The past leaves messages for whoever is lonely enough to read them.",
	"game": "A game is a small world with rules kinder than ours.",
	"harddrive": "We keep words we never send, as if sending were the dangerous part.",
	"movie": "In the dark, other people's lives pass through us like light.",
	"watch_clock": "A clock does not measure time; it only counts our attention.",
	"open_clock": "Time keeps its secrets in the places we watch most.",
	"search_cab": "Closed doors are only questions that haven't been asked.",
	"chess": "To play against yourself is to learn that you cannot lose.",
	"chess_board": "Every move leaves a message for whoever makes the next.",
	"look_out": "A window is the smallest way to leave.",
	"unlock": "A key is only a promise that the world has another side.",
	"leave1": "To go out is to admit the room was never the whole world.",
	"search_attic": "What we store above us is what we cannot bear to throw away.",
	"uncover": "What is covered is not gone, only waiting.",
	"search_conservatory": "Every silent hall is full of music that never got a listener.",
	"compose": "To make a thousand songs is to learn that none of them is the last.",
	"explore_village": "To know a place you have to walk it with no purpose.",
	"watch_sky": "The sky is the only thing older than you that still changes.",
	"search_desk": "An empty page is the bravest thing in a drawer.",
	"write": "To write is to argue with silence and lose gracefully.",
	"piano": "Practice is how time becomes a skill instead of a wound.",
	"graft": "To join two lives on one branch is the oldest kind of hope.",
	"clear": "Before anything can grow, something has to be let go.",
	"tend": "Care is the part of love that can be done alone.",
	"search_shed": "Tools are the memory of hands that are gone.",
	"rummage": "Usefulness hides in the places we call forgotten.",
	"leave2": "A road is a decision that keeps being made.",
	"walk": "The world is bigger than any grief, but only on foot.",
	"search_workshop": "Every ruin is someone's unfinished sentence.",
	"paint": "A thousand canvases, and each one asks the same question.",
	"build": "A house is a promise that time can be kept out, or at least kept company.",
	"search_lib": "Knowledge outlives its readers, patient as stone.",
	"study": "To know everything is to find that the unknown was the point.",
	"leave3": "A home is just a place you decided to come back to.",
	"forest": "A forest is time that decided to stand still and grow.",
	"chart": "We name the stars so they will feel less far.",
	"village": "Cities are what loneliness builds when it finally gathers.",
	"family": "A family is a river: the water changes, the shape remains.",
	"leave4": "Watching is a way of staying while everything else leaves.",
	"rise": "Every empire is certain it is the last one.",
	"fall": "What is built to be eternal is the first thing to be forgotten.",
	"history": "History is what the survivors agree to remember.",
	"compare": "Two truths can both be honest and still never touch.",
	"second": "We repeat our mistakes because they are the only things we truly own.",
	"search_ruins": "Ruins are the future's way of reading us.",
	"glacier": "Patience, at its largest, is a river of ice.",
	"leave5": "To let the ages pass is to stop counting them.",
	"search_fossil": "Beneath every present lies a patient, buried yesterday.",
	"evolve": "Life is the universe slowly learning to look back at itself.",
	"layers": "The earth keeps a diary no one is meant to finish.",
	"drift": "Even the ground you stand on is travelling.",
	"island": "Whatever rises from the sea is only borrowing the land.",
	"search_tubes": "Fire leaves behind glass, so that the heat can still be seen.",
	"ice": "The world breathes in cold and out in green.",
	"leave6": "To look up is the first act of every species that ever wondered.",
	"scan_neb": "Birth is only dust deciding to matter.",
	"planet": "A world begins as a rumour of gravity.",
	"strike": "A single note is the universe agreeing to be heard.",
	"comet": "Some visitors return only because the way home is long.",
	"star": "A star is a promise that burns, and keeps its word until it can't.",
	"swallow": "Home is what the light eventually takes back.",
	"leave7": "After the last home, only direction remains.",
	"listen": "Silence is not the absence of an answer; it may be the answer.",
	"last_note": "A sound no one hears has still been sung.",
	"stars": "Even light must someday run out of ways to be seen.",
	"search_void": "In the deepest dark, the faintest warmth is a kind of company.",
	"holes": "Even the things that swallow everything must end.",
	"photon": "The last light is only a question no one is left to ask.",
	"leave8": "At the end of everything, waiting is the only thing left to do well.",
	"letgo": "To let go is not to lose; it is to finally stop holding.",
}

# Journal entries, shown when a flag is first obtained.
# Flags that follow automatically once others are known: the brass key turns up with
# whichever of the three notes you find last.
# Places found one by one by an action (in a different random order each game)
const REVEALS := {
	"walk": [
		{"flag": "place_workshop", "line": " a shack stands by the road: a painting workshop."},
		{"flag": "place_conservatory", "need": "piano_learned", "line": " A hall with a green roof."},
		{"flag": "place_library", "line": " A great stone building: a university."},
		{"flag": "found_village", "last": true, "line": " Smoke rises over a cluster of roofs: a village."},
	],
}

const AUTO := [
	{"counts": [["wait_apples", 3]], "give": "apples_grown", "line": " The apples are ripe."},
]

static func auto_gives(flags: Dictionary, counts: Dictionary = {}) -> Array:
	var out: Array = []
	for r in AUTO:
		if flags.has(r["give"]):
			continue
		var ok := true
		for w in r.get("when", []):
			if not flags.has(w):
				ok = false
		for c in r.get("counts", []):
			if int(counts.get(c[0], 0)) < int(c[1]):
				ok = false
		if ok:
			out.append(r["give"])
	return out

const NOTES := {
	"seen_yard": "Outside the window, an overgrown yard. Bare earth.",
	"found_almanac": "A stained gardener's almanac, wedged in the kitchen shelf.",
	"know_garden": "The almanac: everything wants light, water, patience.",
	"found_chess": "A chess set, in the cabinet.",
	"door_open": "The front door is unlocked.",
	"found_notebook": "A blank leather notebook, in the desk.",
	"found_letters": "Letters in an unknown language. The attic.",
	"found_seeds": "A tin of seeds, in the shed.",
	"found_tools": "Garden tools. Rusted, but good.",
	"garden_cleared": "The weeds are gone. The earth is ready.",
	"garden_grown": "Tomatoes. Beans. Nobody to share them with.",
	"book_written": "You wrote a whole book. Nobody will read it.",
	"found_scores": "A conservatory near the end of the road, full of unplayed scores.",
	"composed": "You composed a thousand symphonies. The hall was empty.",
	"place_workshop": "A roadside painting workshop.",
	"place_conservatory": "A hall with a green roof beside the road.",
	"place_library": "A university at the end of the road.",
	"explored_village": "You walked every street of the village.",
	"piano_uncovered": "You uncovered the piano.",
	"piano_learned": "Your hands know the piano now.",
	"seen_world": "The road goes everywhere, and ends nowhere.",
	"found_paints": "A roadside painting workshop. Paints, still wet somehow.",
	"found_lumber": "Beams and tools. Enough to build with.",
	"painted": "A thousand canvases. Not one with a face.",
	"built_house": "A house of your own making, in the village.",
	"found_library": "A university. Its halls go on and on.",
	"studied": "You know how everything works. It changes nothing.",
	"forest_grown": "A forest, older than any road you walked.",
	"found_village": "Smoke over a cluster of roofs beside the road: a village.",
	"city_grown": "The hamlet is a city. They never noticed you.",
	"family_done": "The family died out. The city did not notice.",
	"empire_rose": "An empire, risen out of the plain.",
	"empire_fell": "The empire, fallen. Goats in the forum.",
	"found_ice_map": "In the ruins: a drawing of the northern ice.",
	"glacier_done": "A valley, carved by patient ice.",
	"found_fossil": "Bones in the stone. Something lived here.",
	"evolved": "Something looked up and wondered.",
	"seen_layers": "Layers in the rock. Time, written sideways.",
	"drifted": "The map you knew is wrong.",
	"iced": "White, green, white, green.",
	"found_nursery": "A dark nebula. Something is being born in it.",
	"planet_formed": "A world, from dust.",
	"sun_lived": "The sun grew old. Swollen. Red.",
	"swallowed": "Your world is gone, inside the light.",
	"stars_out": "The last stars have gone out.",
	"found_holes": "Dark things that still glow, very faintly.",
	"holes_gone": "Even black holes run out of time.",
	"light_gone": "No light. No heat. No motion.",
	"found_window_note": "A pressed leaf behind the curtain. Autumn, once.",
	"found_shelf_note": "A pressed flower bookmark, with a date older than you can place.",
	"apples_grown": "The apples are ripe.",
	"found_tv_note": "A TV guide behind the set, every show circled. The circles are yours.",
	"found_sleeve_note": "A note in a record sleeve: 'for when the quiet gets too loud'.",
	"found_old_message": "An unsent message on the old computer, to someone with no name.",
	"found_chess_note": "Taped under the chessboard: 'Your move.' In your handwriting.",
	"heard_music": "Music. You'd forgotten what a melody was for.",
	"found_photo": "A folded photograph behind the clock. A smile you can't place.",
	"found_telescope": "A brass telescope, wrapped in oilcloth, in the attic.",
	"can_cook": "You cooked a feast. You set two places, out of habit.",
	"grafted": "A new apple. Yours.",
	"charted_stars": "You've mapped the sky. It will need redrawing.",
	"wrote_history": "A history of the empire, in your own hand.",
	"know_cycles": "Rise, fall, forget. Round and round.",
	"second_empire": "A second empire. The same mistakes under new banners.",
	"island_born": "A volcano built an island, then the sea took it back.",
	"found_crystal": "A crystal that rings when you tap it.",
	"comet_seen": "A comet on a ten-million-year orbit. Company, of a sort.",
	"crystal_sung": "You struck the crystal. The dust seemed to listen.",
	"heard_nothing": "You listened for a signal. There was none.",
	"crystal_last": "The last note, travelling forever.",
}

static var _eras: Array = []

static func eras() -> Array:
	if _eras.is_empty():
		_eras = _build()
	return _eras

static func _build() -> Array:
	var e: Array = []

	# ------------------------------------------------------------- 0  THE ROOM
	e.append({
		"name": "The Room", "start_x": 230.0, "xmax": 425.0,
		"intro": "You have lost count of the days. You can't remember the last time you were tired. You have to pass time.",
		"hints": [],
		"hs": [
			H("shelf", "Bookshelf", 37, [
				A("read_novel", "Read a novel", "10 hours", 10 * HOUR, 4, .6, "book", "The ending was good. You knew it would be. You've read it before."),
				A("search_shelf", "Search behind the books", "15 min", 15 * MIN, 4, .5, "search", "The second time through, you notice the books are shelved two deep. Behind the novels, a pressed flower used as a bookmark. The date on it is older than you can place.", {"needs": [["read_novel", 2]], "once": true, "search": true, "give": ["found_shelf_note"]}),
				A("read_all", "Read every book on the shelf", "10 days", 10 * DAY, 5, .5, "book", "You've read every one. The stories have worn smooth; none of them can surprise you now.", {"needs": [["read_novel", 3]], "once": true, "give": ["read_every_book"], "exhausts": ["read_novel"]}),
			]),
			H("gramophone", "Gramophone", 80, [
				A("record", "Play a record", "1 hour", HOUR, 4, .6, "music", "The needle crackles. The song is exactly as long as you remember.", {"give": ["heard_music"]}),
				A("sleeves", "Look through the record sleeves", "15 min", 15 * MIN, 4, .5, "search", "In one sleeve, a handwritten note: 'for when the quiet gets too loud'.", {"needs": [["record", 2]], "once": true, "search": true, "give": ["found_sleeve_note"]}),
				A("record_all", "Listen to every record in the box", "3 days", 3 * DAY, 5, .5, "music", "Every song is a worn groove now. The needle only repeats what you already know.", {"needs": [["record", 3]], "once": true, "give": ["listened_all"], "exhausts": ["record"]}),
			]),
			H("computer", "Computer", 148, [
				A("game", "Play a video game", "3 hours", 3 * HOUR, 5, .6, "game", "Level twelve. You've beaten it before. You beat it again."),
				A("harddrive", "Search the hard drive", "1 hour", HOUR, 4, .5, "search", "Buried in an old folder: a half-written message to someone, never sent.", {"needs": [["game", 2]], "once": true, "search": true, "give": ["found_old_message"]}),
				A("game_all", "Beat every game on the drive", "30 days", 30 * DAY, 5, .5, "game", "There is nothing left to win. The score screen only repeats your name.", {"needs": [["game", 3]], "once": true, "exhausts": ["game"]}),
			]),
			H("tv", "Television", 183, [
				A("movie", "Watch a movie", "2 hours", 2 * HOUR, 4, .6, "tv", "The credits roll. You stay for every name."),
				A("tv_back", "Look behind the television", "1 hour", HOUR, 4, .5, "search", "Taped behind the set: a TV guide, every show circled. The circles are your own.", {"needs": [["movie", 2]], "once": true, "search": true, "give": ["found_tv_note"]}),
				A("movie_all", "Watch every film in the cabinet", "15 days", 15 * DAY, 5, .5, "tv", "The plots blur into one long, familiar film. You stop reaching for the remote.", {"needs": [["movie", 3]], "once": true, "exhausts": ["movie"]}),
			]),
			H("clock", "Wall clock", 215, [
				A("watch_clock", "Watch the clock", "1 hour", HOUR, 3, .4, "clock", "Tick. Tick. The second hand goes all the way round. Sixty times."),
				A("open_clock", "Open the clock case", "1 hour", HOUR, 4, .5, "search", "The second time round you notice the glass isn't quite shut. Behind it, a photograph folded small. Someone smiling. You can't remember their name.", {"needs": [["watch_clock", 2]], "once": true, "search": true, "give": ["found_photo"]}),
				A("clock_all", "Watch the clock until it stops meaning anything", "1 day", DAY, 5, .5, "clock", "You watch until 'time' sounds like a word in a language you never learned.", {"needs": [["watch_clock", 3]], "once": true, "exhausts": ["watch_clock"]}),
			]),
			H("cabinet", "Cabinet", 247, [
				A("search_cab", "Search the cabinet", "15 min", 15 * MIN, 4, .5, "search", "Under the tablecloths: a chess set, never opened.", {"once": true, "search": true, "give": ["found_chess"]}),
			]),
			H("table", "Chess table", 310, [
				A("chess", "Play chess against yourself", "1 day", DAY, 4, .6, "chess", "A draw. Again. You shake your own hand."),
				A("chess_board", "Look under the board", "1 hour", HOUR, 4, .5, "search", "Taped under the board, a slip of paper. 'Your move.' It's in your handwriting.", {"needs": [["chess", 2]], "once": true, "search": true, "give": ["found_chess_note"]}),
				A("chess_all", "Play every possible game", "5 days", 5 * DAY, 5, .5, "chess", "Every opening is a repetition now. The board is only wood and paint.", {"needs": [["chess", 3]], "once": true, "exhausts": ["chess"]}),
			], ["found_chess"]),
			H("window", "Window", 340, [
				A("look_out", "Look outside", "1 hour", HOUR, 3, .4, "window", "The yard is overgrown. Bare earth, waiting for something.", {"give": ["seen_yard"]}),
				A("sill", "Search the windowsill", "15 min", 15 * MIN, 4, .5, "search", "Between the curtain and the glass, a pressed leaf. Autumn, once.", {"needs": [["look_out", 2]], "once": true, "search": true, "give": ["found_window_note"]}),
				A("window_all", "Watch the yard until it stops changing", "12 days", 12 * DAY, 5, .5, "window", "The yard has become a painting you've memorised. Nothing in it moves for you anymore.", {"needs": [["look_out", 3]], "once": true, "exhausts": ["look_out"]}),
			]),
			H("door", "Front door", 400, [
				A("leave1", "Step outside", "", 0.0, 3, .5, "door", "", {"min_years": 40 * DAY, "exit": true, "once": true}),
			]),
		],
	})

	# ------------------------------------------------------------ 1  THE HOUSE
	e.append({
		"name": "The House", "start_x": 150.0, "xmax": 408.0,
		"intro": "The room was too small for this much time. The house is bigger. The yard is bigger still. You have to pass time.",
		"hints": [
			{"not": "found_notebook", "text": "The desk has drawers. You never needed paper before."},
			{"not": "found_seeds", "text": "There's a shed at the end of the yard."},
			{"not": "found_tools", "need": "found_seeds", "text": "A shed holds more than one thing."},
			{"not": "garden_cleared", "need": "found_tools", "text": "The earth is waiting. You know what the almanac said."},
			{"not": "found_letters", "text": "The attic. You haven't been up there in a century."},
			{"not": "garden_grown", "need": "garden_cleared", "text": "Plant. Water. Wait. You're good at waiting."},
		],
		"hs": [
			H("attic", "Attic ladder", 22, [
				A("search_attic", "Search the attic", "15 min", 15 * MIN, 5, .5, "search", "A bundle of letters in a language you don't know, and, under a sheet of oilcloth, a brass telescope.", {"once": true, "search": true, "give": ["found_letters", "found_telescope"]}),
			]),
			H("desk", "Desk", 98, [
				A("search_desk", "Search the drawers", "15 min", 15 * MIN, 4, .5, "search", "A blank leather notebook. Waiting for twenty years.", {"once": true, "search": true, "give": ["found_notebook"]}),
				A("write", "Start writing a book", "3 months", 0.25, 5, .55, "write", "A first sentence, crossed out, rewritten, kept.", {"req": ["found_notebook", "read_every_book"], "once": true}),
				A("write2", "Continue writing your book", "3 months", 0.25, 5, .55, "write", "The middle is where books go to be abandoned. You stay.", {"needs": [["write", 1]], "once": true}),
				A("write3", "Finish your book", "3 months", 0.25, 5, .55, "write", "You wrote it anyway.", {"needs": [["write2", 1]], "once": true, "give": ["book_written"], "exhausts": ["write"]}),
			]),
			H("piano", "Piano", 187, [
				A("uncover", "Take the sheet off the piano", "5 min", 5 * MIN, 4, .5, "search", "Dust rises in the light. Under it, black lacquer and yellowed keys.", {"once": true, "give": ["piano_uncovered"]}),
				A("piano", "Start learning the piano", "3 months", 0.25, 5, .55, "piano", "Your fingers remember nothing. They learn it all over again.", {"req": ["listened_all", "piano_uncovered"], "lock_msgs": {"piano_uncovered": "It is still under its sheet."}, "once": true}),
				A("piano2", "Continue learning the piano", "3 months", 0.25, 5, .55, "piano", "The same scale, a thousand times. It begins to sound like intention.", {"needs": [["piano", 1]], "once": true}),
				A("piano3", "Finish learning the piano", "3 months", 0.25, 5, .55, "piano", "You play the same sonata until it plays you.", {"needs": [["piano2", 1]], "once": true, "give": ["piano_learned"], "exhausts": ["piano"]}),
			]),
			H("stove", "Stove", 58, [
				A("search_kitchen", "Search the kitchen shelf", "15 min", 15 * MIN, 4, .5, "search", "Wedged between the cookbooks: a stained gardener's almanac.", {"once": true, "search": true, "give": ["found_almanac"]}),
				A("read_almanac", "Read the gardener's almanac", "4 days", 4 * DAY, 5, .5, "none", "Light, water, patience. You have always had the last one.", {"req": ["found_almanac"], "once": true, "give": ["know_garden"]}),
			]),
			H("scope", "Telescope", 42, [
				A("watch_sky", "Watch the sky", "90 days", 90 * DAY, 6, .5, "sky", "Stars wheel past the window. You know them all. You watch anyway.", {"max_uses": 3}),
			], ["found_telescope"]),
			H("apple", "Apple tree", 232, [
				A("wait_apples", "Wait for the apples to grow", "30 days", 30 * DAY, 5, .5, "apple", "Blossom, then bud, then something green and hard. The tree takes its time, and so do you."),
				A("graft", "Graft a new variety", "2 years", 2.0, 6, .5, "apple", "One branch, two trees. In two years: a new apple. Your apple.", {"req": ["found_tools", "apples_grown"], "once": true, "give": ["grafted"], "lock": "You've nothing to cut with."}),
			]),
			H("garden", "Garden plot", 265, [
				A("clear", "Clear the weeds", "4 days", 4 * DAY, 5, .5, "garden", "Rotten roots, hard soil. Clean earth, finally.", {"req": ["found_tools", "know_garden"], "once": true, "give": ["garden_cleared"], "lock": "You'd need tools, and to know what to plant."}),
				A("tend", "Plant and tend the garden", "1 year", 1.0, 6, .55, "garden", "Tomatoes, beans, a lopsided pumpkin. Nobody to give them to.", {"req": ["garden_cleared", "found_seeds"], "soft": [["found_tools", "tool"], ["know_garden", "knowledge"]], "lock_msgs": {"garden_cleared": "The ground is still choked with weeds.", "found_seeds": "I have nothing to plant."}, "give": ["garden_grown"]}),
			]),
			H("shed", "Shed", 323, [
				A("search_shed", "Search the shed", "15 min", 15 * MIN, 5, .5, "search", "A tin of seeds, labelled in a careful hand. Still good.", {"once": true, "search": true, "give": ["found_seeds"]}),
				A("rummage", "Rummage for tools", "15 min", 15 * MIN, 5, .5, "search", "A spade, a rake, shears. Rusted, but they'll do.", {"req": ["found_seeds"], "once": true, "search": true, "give": ["found_tools"], "lock": "You haven't looked inside yet."}),
			]),
			H("gate", "Garden gate", 396, [
				A("leave2", "Follow the road", "", 0.0, 3, .5, "walk", "", {"req": ["found_letters", "found_telescope"], "min_years": 1.0, "exit": true, "once": true}),
			]),
		],
	})

	# --------------------------------------------------------- 2  THE DECADES
	e.append({
		"name": "The Decades", "start_x": 30.0, "xmax": 440.0,
		"intro": "Years stop having names. The seasons blur into each other. You have to pass time.",
		"hints": [
			{"not": "seen_world", "text": "The road is right there. It goes on. So can you."},
			{"not": "found_paints", "need": "place_workshop", "text": "There was a painting workshop by the road. A shack, really."},
			{"not": "found_lumber", "need": "found_paints", "text": "That shack had more than paint."},
			{"not": "found_library", "need": "place_library", "text": "A grey stone building stood at the end of the road. A university."},
			{"not": "built_house", "need": "found_village", "text": "The village has an empty plot. Good soil, good light."},
			{"not": "studied", "need": "found_library", "text": "All those books, and you still have time."},
			{"not": "painted", "need": "found_paints", "text": "A canvas is just a window you build yourself."},
			{"not": "found_scores", "need": "place_conservatory", "text": "A hall with a green roof, near the end of the road. Music used to be made there."},
		],
		"hs": [
			H("milestone", "Milestone", 30, [
				A("walk", "Walk across the world", "3 to 10 years", 6.5, 7, .5, "walk", "The road goes on.", {"give": ["seen_world"], "sec_range": [3.0, 10.0]}),
			]),
			H("workshop", "Painting workshop", 100, [
				A("search_workshop", "Search the painting workshop", "1 day", DAY, 5, .5, "search", "Paints still wet. Brushes, easels, blank canvases. Someone left in a hurry, long ago.", {"once": true, "search": true, "give": ["found_paints", "found_lumber"], "req": ["place_workshop"], "lock": "You haven't walked far enough to find it."}),
			], ["place_workshop"]),
			H("easel", "Easel", 170, [
				A("paint", "Paint a thousand canvases", "60 years", 60.0, 7, .5, "paint", "Every one a window. None has a person in it.", {"give": ["painted"]}),
			], ["found_paints"]),
			H("clearing", "The village", 240, [
				A("explore_village", "Explore the village", "1 day", DAY, 5, .5, "search", "Narrow streets, a well, a bakery with the oven still warm. Everyone just left, or never came.", {"req": ["found_village"], "once": true, "search": true, "give": ["explored_village"], "lock": "There is no village to explore."}),
				A("build", "Build a house with your hands", "25 years", 25.0, 7, .5, "build", "It stands. It will outlast you. You will outlast it.", {"req": ["found_village", "explored_village"], "once": true, "give": ["built_house"], "lock": "You have not looked around the village yet."}),
							A("leave3", "Move into your house", "", 0.0, 3, .5, "walk", "", {"req": ["built_house"], "hide": ["built_house"], "exit": true, "once": true}),
			], ["found_village"]),
			H("conservatory", "Conservatory", 310, [
				A("search_conservatory", "Search the conservatory", "1 day", DAY, 5, .5, "search", "Rows of empty chairs. A grand piano under the dust, and stacks of scores nobody ever played.", {"req": ["piano_learned"], "once": true, "search": true, "give": ["found_scores"]}),
				A("compose", "Compose a thousand symphonies", "60 years", 60.0, 8, .5, "piano", "A thousand ways of saying the same thing. No one in the hall to hear any of them.", {"req": ["found_scores"], "once": true, "give": ["composed"], "lock": "You have nothing to write on."}),
			], ["place_conservatory"]),
			H("library", "University", 380, [
				A("search_lib", "Search the university", "1 day", DAY, 5, .5, "search", "Lecture halls that go on and on. Whole sciences, uncatalogued.", {"once": true, "search": true, "give": ["found_library"]}),
				A("study", "Study every science", "120 years", 120.0, 8, .5, "learn", "You understand how everything works. It doesn't help.", {"req": ["found_library"], "once": true, "give": ["studied"], "lock": "You haven't found where to start."}),
			], ["place_library"]),
		],
	})

	# ------------------------------------------------------- 3  THE CENTURIES
	e.append({
		"name": "The Centuries", "start_x": 40.0,
		"intro": "You stop making things. You start watching them. You have to pass time.",
		"hints": [
			{"not": "forest_grown", "text": "An acorn is a forest, if you wait."},
			{"not": "city_grown", "need": "found_village", "text": "That hamlet. You wonder where it will be in a while."},
			{"not": "family_done", "text": "Somewhere in the valley, a family. Someone has your laugh. Someone else's, rather."},
			{"not": "charted_stars", "text": "The telescope points at the ground. Try the sky."},
		],
		"hs": [
			H("oak", "Old oak", 70, [
				A("forest", "Raise a forest from a seed", "400 years", 400.0, 8, .4, "forest", "The oaks are older than any language you speak.", {"once": true, "give": ["forest_grown"]}),
			]),
			H("telescope", "Telescope", 150, [
				A("chart", "Chart the stars", "200 years", 200.0, 5, .5, "search", "Four thousand stars, named by you. They will move. You'll redraw them.", {"once": true, "search": true, "give": ["charted_stars"]}),
			], ["found_telescope"]),
			H("village", "The village", 190, [
				A("village", "Watch the village become a city", "600 years", 600.0, 9, .4, "village", "They built walls, then streets, then forgot why.", {"req": ["found_village"], "once": true, "give": ["city_grown"], "lock": "You haven't found anything to watch."}),
			], ["found_village"]),
			H("ledger", "Stone table", 228, [
				A("family", "Follow one family through time", "300 years", 300.0, 9, .4, "family", "A grandmother, and later her great-great-grandson. Same laugh.", {"once": true, "give": ["family_done"]}),
			]),
			H("edge", "The high hill", 308, [
				A("leave4", "Stay. Keep watching.", "", 0.0, 3, .5, "walk", "", {"req": ["family_done", "charted_stars"], "exit": true, "once": true, "lock": "There's more to watch down there, and more above."}),
			]),
		],
	})

	# ------------------------------------------------------- 4  THE MILLENNIA
	e.append({
		"name": "The Millennia", "start_x": 50.0,
		"intro": "Your own memories begin to feel like somebody else's story. You have to pass time.",
		"hints": [
			{"not": "empire_rose", "text": "The plain below is empty. For now."},
			{"not": "empire_fell", "need": "empire_rose", "text": "Everything that rises has a way of coming down."},
			{"not": "found_ice_map", "need": "empire_fell", "text": "Nobody looks through ruins. You could."},
			{"not": "glacier_done", "need": "found_ice_map", "text": "Something is happening to the north. Slowly."},
		],
		"hs": [
			H("parapet", "Stone parapet", 100, [
				A("rise", "Watch an empire rise", "2,000 years", 2000.0, 10, .3, "rise", "They carved their names in marble. You can still read them.", {"once": true, "give": ["empire_rose"]}),
				A("fall", "Watch it crumble", "1,500 years", 1500.0, 10, .3, "fall", "Vines in the senate. A goat on the throne.", {"req": ["empire_rose"], "once": true, "give": ["empire_fell"], "lock": "There's nothing to crumble yet."}),
			]),
			H("scribe", "Scribe's desk", 150, [
				A("history", "Write the empire's history", "300 years", 300.0, 8, .4, "write", "Twelve volumes. You were the only one who kept count.", {"once": true, "give": ["wrote_history"]}),
				A("compare", "Compare it with their histories", "50 years", 50.0, 6, .4, "write", "They remember a glorious past you don't recognize. Neither of you is lying.", {"req": ["wrote_history", "empire_fell"], "once": true, "give": ["know_cycles"], "lock": "The story isn't over yet."}),
				A("second", "Watch a second empire rise", "1,200 years", 1200.0, 10, .3, "rise", "The same mistakes, under new banners.", {"req": ["know_cycles"], "once": true, "give": ["second_empire"], "lock": "You'd need to understand the pattern first."}),
			], ["empire_rose"]),
			H("ruins", "The ruins", 205, [
				A("search_ruins", "Search the ruined archive", "3 years", 3.0, 5, .5, "search", "A cracked map. The northern ice, drawn with great care. Drawn with fear.", {"once": true, "search": true, "give": ["found_ice_map"], "req": ["empire_fell"], "lock": "There are no ruins yet."}),
			], ["empire_rose"]),
			H("ridge", "North ridge", 275, [
				A("glacier", "Watch a glacier carve a valley", "50,000 years", 50000.0, 11, .3, "glacier", "Slower than anything you've ever watched. You loved it.", {"req": ["found_ice_map"], "once": true, "give": ["glacier_done"], "lock": "You don't know where to look."}),
			], ["empire_fell"]),
			H("stair", "The stair down", 312, [
				A("leave5", "Let the ages pass", "", 0.0, 3, .5, "walk", "", {"req": ["glacier_done"], "exit": true, "once": true, "lock": "You haven't seen what the ice can do."}),
			]),
		],
	})

	# ------------------------------------------------------------ 5  DEEP TIME
	e.append({
		"name": "Deep Time", "start_x": 50.0,
		"intro": "Even mountains start to look impatient. You have to pass time.",
		"hints": [
			{"not": "found_fossil", "text": "The bones in the rock. There were bones."},
			{"not": "evolved", "need": "found_fossil", "text": "Something lived here. Something will again."},
			{"not": "seen_layers", "need": "evolved", "text": "Look at the cliff. It's a book."},
			{"not": "drifted", "need": "seen_layers", "text": "The layers say the land moved."},
			{"not": "iced", "need": "drifted", "text": "The frozen ridge. It comes and goes."},
		],
		"hs": [
			H("fossils", "Fossil bed", 90, [
				A("search_fossil", "Search the strata", "10,000 years", 1e4, 5, .5, "search", "A skull. Smaller than your hand. Older than your language.", {"once": true, "search": true, "give": ["found_fossil"]}),
				A("evolve", "Watch a species evolve", "5 million years", 5e6, 11, .3, "evolve", "Something looked up and wondered. You waved. It didn't see you.", {"req": ["found_fossil"], "once": true, "give": ["evolved"], "lock": "You've no idea what lived here."}),
			]),
			H("cliff", "Cliff face", 180, [
				A("layers", "Study the layered rock", "100,000 years", 1e5, 6, .5, "search", "Every stripe a million years. You read it like a ledger.", {"req": ["evolved"], "once": true, "search": true, "give": ["seen_layers"], "lock": "It's just a cliff to you. For now."}),
				A("drift", "Watch the continents drift", "100 million years", 1e8, 11, .3, "drift", "The map you memorized is wrong again.", {"req": ["seen_layers"], "once": true, "give": ["drifted"], "lock": "You don't see what the stone says."}),
			]),
			H("volcano", "Volcano", 222, [
				A("island", "Watch a volcano build an island", "2 million years", 2e6, 9, .3, "volcano", "It rose, it fell, it was sea again. The whole story in a blink.", {"once": true, "give": ["island_born"]}),
				A("search_tubes", "Search the lava tubes", "20,000 years", 2e4, 5, .5, "search", "In a glassy tube: a crystal that rings when you tap it.", {"req": ["island_born"], "once": true, "search": true, "give": ["found_crystal"], "lock": "There's no island yet."}),
			], ["evolved"]),
			H("ridge2", "Frozen ridge", 255, [
				A("ice", "Watch the ice ages come and go", "10 million years", 1e7, 10, .3, "ice", "White, green, white, green. A slow breathing.", {"once": true, "give": ["iced"]}),
			], ["drifted"]),
			H("sky", "The open sky", 310, [
				A("leave6", "Look up", "", 0.0, 3, .5, "walk", "", {"req": ["iced"], "exit": true, "once": true, "lock": "The Earth still has more to show."}),
			]),
		],
	})

	# ---------------------------------------------------------------- 6  STARS
	e.append({
		"name": "Stars", "start_x": 50.0,
		"intro": "The Earth was a habit you can no longer afford. You have to pass time.",
		"hints": [
			{"not": "found_nursery", "text": "Out there, in the dark. A cloud. Something forming."},
			{"not": "planet_formed", "need": "found_nursery", "text": "Dust wants to be a world."},
			{"not": "sun_lived", "need": "planet_formed", "text": "The star will do its slow work."},
			{"not": "swallowed", "need": "sun_lived", "text": "It's old now. And hungry."},
		],
		"hs": [
			H("nebula", "Dark nebula", 90, [
				A("scan_neb", "Search the dust for a nursery", "1 million years", 1e6, 6, .5, "search", "Deep inside the cloud, a knot of gas begins to spin.", {"once": true, "search": true, "give": ["found_nursery"]}),
				A("planet", "Watch a planet form", "100 million years", 1e8, 12, .2, "planet", "Dust, then rock, then a world. Nobody's home yet.", {"req": ["found_nursery"], "once": true, "give": ["planet_formed"], "lock": "You haven't found where it begins."}),
			]),
			H("crystal", "The crystal", 28, [
				A("strike", "Strike the crystal", "a moment", 1.0 / 31557600.0, 6, .3, "music", "The note spreads through the dust. For a moment the cloud hums back.", {"once": true, "give": ["crystal_sung"]}),
			], ["found_crystal"]),
			H("comet", "Comet", 130, [
				A("comet", "Watch a comet circle the sun", "10 million years", 1e7, 9, .3, "comet", "It comes back, and back. You begin to feel it's keeping you company.", {"once": true, "give": ["comet_seen"]}),
			], ["found_nursery"]),
			H("star", "Young star", 175, [
				A("star", "Watch a sun live its life", "5 billion years", 5e9, 12, .2, "star", "It burned steadily, as if it had somewhere to be.", {"once": true, "give": ["sun_lived"]}),
			], ["planet_formed"]),
			H("giant", "Red giant", 250, [
				A("swallow", "Watch your world swallowed by its sun", "1 billion years", 1e9, 14, .2, "swallow", "It was beautiful, for a moment. Then it was inside the light.", {"once": true, "give": ["swallowed"]}),
			], ["sun_lived"]),
			H("beyond", "Beyond", 310, [
				A("leave7", "Go on", "", 0.0, 3, .5, "walk", "", {"req": ["swallowed"], "exit": true, "once": true, "lock": "You aren't done watching."}),
			]),
		],
	})

	# ------------------------------------------------------------ 7  THE LONG DARK
	e.append({
		"name": "The Long Dark", "start_x": 50.0,
		"intro": "There are fewer and fewer things left to look at. You have to pass time.",
		"hints": [
			{"not": "stars_out", "text": "The stars are not forever. They were never going to be."},
			{"not": "found_holes", "need": "stars_out", "text": "Something is still giving off heat. Barely."},
			{"not": "holes_gone", "need": "found_holes", "text": "Those dark things are leaking away."},
			{"not": "light_gone", "need": "holes_gone", "text": "One last photon, somewhere."},
		],
		"hs": [
			H("signal", "The silence", 38, [
				A("listen", "Listen for a signal", "10^20 years", 1e20, 9, .4, "search", "You listen to the whole universe. It has nothing to say. You listen anyway.", {"once": true, "search": true, "give": ["heard_nothing"]}),
				A("last_note", "Strike the crystal one last time", "a moment", 1.0 / 31557600.0, 7, .2, "music", "The note leaves. It will travel forever, or until there's nothing left to carry it.", {"req": ["found_crystal", "heard_nothing"], "once": true, "give": ["crystal_last"], "lock": "You've nothing to strike, and no one to hear it."}),
			], ["stars_out"]),
			H("sky7", "Fading stars", 100, [
				A("stars", "Watch the last stars burn out", "100 trillion years", 1e14, 13, .2, "stars", "One by one. You say goodnight to each of them.", {"once": true, "give": ["stars_out"]}),
			]),
			H("void", "The dark", 190, [
				A("search_void", "Search the dark for anything still burning", "10^40 years", 1e40, 8, .5, "search", "Black holes, dim as breath. They've been there all along.", {"once": true, "search": true, "give": ["found_holes"], "req": ["stars_out"], "lock": "There are still stars. You don't need to look."}),
				A("holes", "Watch the black holes evaporate", "10^100 years", 1e100, 13, .2, "holes", "Even the darkness runs out of itself.", {"req": ["found_holes"], "once": true, "give": ["holes_gone"], "lock": "You haven't found them."}),
			], ["stars_out"]),
			H("photon", "The last light", 262, [
				A("photon", "Watch the last light fade", "...", 1e106, 12, .2, "photon", "A single photon, crossing an empty universe. Then not even that.", {"once": true, "give": ["light_gone"]}),
			], ["holes_gone"]),
			H("end7", "Nothing", 312, [
				A("leave8", "Sit. Wait.", "", 0.0, 3, .5, "walk", "", {"req": ["light_gone"], "exit": true, "once": true, "lock": "Not yet. There's a little light left."}),
			]),
		],
	})

	# ---------------------------------------------------------------- 8  NOTHING
	e.append({
		"name": "Nothing", "start_x": 160.0,
		"intro": "There is nothing left to watch. Only you. You have to pass time.",
		"hints": [{"not": "ended", "text": "Nothing remains but to stop holding on."}],
		"hs": [
			H("self", "Yourself", 160, [
				A("letgo", "Let go", "forever", 1e200, 20, 0.0, "dissolve", "", {"once": true}),
			]),
		],
	})
	return e
