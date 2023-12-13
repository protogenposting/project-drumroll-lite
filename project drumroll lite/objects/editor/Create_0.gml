/// @description Loading all the files
//setting up values
notes=[]
events=[]
songSelected=song1
bpm=120
rows=4
botplay=false

//change fps to 120
game_set_speed(144,gamespeed_fps)

function download_level(){
	var _string=""
	
	var _levelName=get_string("level name","")
	var _userName=get_string("username","")
	for(var i=0;i<1000;i++)
	{
		try{
			function onAttemptFunction(Success, ErrorMessage, RetryNumber){
				//show_message(ErrorMessage)
			}
			var _data=GJDataFetch(_levelName+"@"+_userName+"_"+string(i),false,onAttemptFunction,5)
			show_debug_message(string(_data))
			_string=_string+string(_data)
			show_debug_message(i)
		}
		catch(e)
		{
			//show_debug_message(e)
			continue;
		}
	}
	show_message(_string)
	_string=base64_decode(_string)
	show_message(_string)
	var str=json_parse(_string)
	var _level=get_open_filename("project drumroll files","level.txt")
	save_file_encode(str,_level)
}

function upload_level(){
	var _strings=[]
	
	var _file=get_open_filename("project drumroll files","level.txt")
	var _buffer = buffer_load(_file)
	var _string = buffer_read(_buffer,buffer_string)
	buffer_delete(_buffer)
	
	while(string_length(_string)>=200)
	{
		var _str=string_copy(_string,1,200)
		_string=string_delete(_string,1,200)
		array_push(_strings,_str)
	}
	
	/*_file=get_open_filename(".ogg files","level.ogg")
	_buffer = buffer_load(_file)
	var _string2 = buffer_read(_buffer,buffer_string)
	buffer_delete(_buffer)*/
	
	_string=base64_decode(_string)
	show_debug_message(_string)
	var _levelName=get_string("level name","")
	var _userName=get_string("username","")
	if(_userName!=""&&_levelName!="")
	{
		function onAttemptFunction(Success, ErrorMessage, RetryNumber){
			//show_message(ErrorMessage)
		}
		var i=0
		repeat(array_length(_strings))
		{
			GJDataSet(_levelName+"@"+_userName+"_"+string(i),_strings[i],false,onAttemptFunction,1)
			i++
		}
		//GJDataSet(_levelName+"@"+_userName+"_song",_string2,false,onAttemptFunction,1)
	}
}

/// @function                fnf_convert()
/// @description             Used to convert a Friday Night Funkin chart to a Project Drumroll chart.
function fnf_convert(){
	var _file=get_open_filename("fnf chart","level.json")
	if(_file!=""&&file_exists(_file))
	{
		var _fnf=load_file(_file)
		
		#region getting input about the chart from the player
		show_message("song length: "+string(array_length(_fnf.song.notes)))
		bpm=_fnf.song.bpm
		var bfOnly=show_question("only use boyfriend?")
		var opponentAlt=false
		var altNoteId=0
		if(!bfOnly)
		{
			opponentAlt=show_question("make opponent use different notes?")
			if(opponentAlt)
			{
				altNoteId=get_integer("note id",1)
			}
		}
		var totalRows=get_integer("rows",4)
		#endregion
		
		#region converting notes to project drumroll notes
		var tempNotes=[]
		for(var i=0;i<array_length(_fnf.song.notes);i++)
		{
			var type=0
			if(variable_struct_exists(_fnf.song.notes[i],"bpm"))
			{
				var current_bpm=_fnf.song.notes[i].bpm
			}
			else
			{
				var current_bpm=bpm
			}
			var current_notes=_fnf.song.notes[i].sectionNotes
			if(bfOnly&&!_fnf.song.notes[i].mustHitSection)
			{
				continue;
			}
			if(opponentAlt&&!_fnf.song.notes[i].mustHitSection)
			{
				type=altNoteId
			}
			var times=[]
			for(var o=0;o<array_length(current_notes);o++)
			{
				var noteBeat=current_notes[o][0]/1000
				var noteLane=current_notes[o][1]
				if(noteLane+1>totalRows)
				{
					noteLane-=totalRows
				}
				var beatLength=60/bpm
				noteBeat=noteBeat/beatLength
				array_push(tempNotes,[noteBeat,noteLane,false,false,false,type])
				array_push(times,noteBeat)
			}
		}
		#endregion
		
		repeat(15)
		{
			show_debug_message("")
		}
		show_debug_message(tempNotes)
		show_message("done!")
		var newFile=string_delete(_file,string_length(_file)-6,5)+".txt"
		save_file_encode({dbpm: editor.bpm,eventy: tempNotes, rows: totalRows},newFile)
		show_message("saved to "+newFile)
	}
}
/// @function                game_play()
/// @description             Asks the player for a Project Drumroll chart file and a .ogg audio file then allows the player to play the level.
function game_play()
{
	#region load audio file
	//get the file
	var _audio=get_open_filename("audio files","level.ogg")
	//load the file
	if(_audio!=""&&file_exists(_audio))
	{
		songSelected=audio_create_stream(_audio)
	}
	#endregion
	
	#region load level file
	//get the file
	var _file=get_open_filename("project drumroll files","level.txt")
	if(_file!="")
	{
		//load and decode the file
		var _loaded=load_file_decode(_file)
		if(_loaded!=false)
		{
			//change the bpm to the file's default bpm (named dbpm because i was dumb lol)
			bpm=_loaded.dbpm
			//convert all of the Project Drumroll note arrays into more readable Project Drumroll note structs.
			for(var i=0;i<array_length(_loaded.eventy);i++)
			{
				//convert old system of notes to new system
				var _note=create_note(_loaded.eventy[i][0],_loaded.eventy[i][1],0)
				if(array_length(_loaded.eventy[i])>5)
				{
					_note.type=_loaded.eventy[i][5]
				}
				array_push(notes,_note)
			}
			//if it has a definition of how many rows are in the file, change the rows to that
			if(variable_struct_exists(_loaded,"rows"))
			{
				rows=_loaded.rows
			}
			//if it has events, add teh events
			if(variable_struct_exists(_loaded,"events"))
			{
				for(var i=0;i<array_length(_loaded.events);i++)
				{
					//convert old system of notes to new system
					array_push(events,_loaded.events[i])
				}
			}
		}
	}
	#endregion
	room_goto(rm_play)
}
