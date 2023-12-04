/// @description Loading all the files
//setting up values
notes=[]
songSelected=song1
bpm=120

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
	}
}
room_goto(rm_play)
#endregion