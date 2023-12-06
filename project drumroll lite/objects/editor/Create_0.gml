/// @description Loading all the files
//setting up values
notes=[]
events=[]
songSelected=song1
bpm=120
rows=4

function fnf_convert(){
	var _file=get_open_filename("fnf chart","level.json")
	if(_file!=""&&file_exists(_file))
	{
		var _fnf=load_file(_file)
		show_message("song length: "+string(array_length(_fnf.song.notes)))
		bpm=_fnf.song.notes[1].bpm
		var bfOnly=show_question("only use boyfriend?")
		var tempNotes=[]
		var totalRows=get_integer("rows",4)
		for(var i=0;i<array_length(_fnf.song.notes);i++)
		{
			var current_bpm=_fnf.song.notes[i].bpm
			var current_notes=_fnf.song.notes[i].sectionNotes
			if(bfOnly&&!_fnf.song.notes[i].mustHitSection)
			{
				continue;
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
				array_push(tempNotes,[noteBeat,noteLane,false,false,false])
				array_push(times,noteBeat)
			}
		}
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

function game_play()
{
	#region load audio file
	var _audio=get_open_filename("audio files","level.ogg")
	if(_audio!=""&&file_exists(_audio))
	{
		songSelected=audio_create_stream(_audio)
	}
	#endregion
	#region load level file
	var _file=get_open_filename("project drumroll files","level.txt")
	if(_file!="")
	{
		var _loaded=load_file_decode(_file)
		if(_loaded!=false)
		{
			bpm=_loaded.dbpm
			for(var i=0;i<array_length(_loaded.eventy);i++)
			{
				//convert old system of notes to new system
				array_push(notes,create_note(_loaded.eventy[i][0],_loaded.eventy[i][1],0))
			}
			if(variable_struct_exists(_loaded,"rows"))
			{
				rows=_loaded.rows
			}
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
	room_goto(rm_play)
}
#endregion