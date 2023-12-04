/// @description Insert description here
// You can write your code in this editor
notes=[]
songSelected=song1
bpm=120
var _audio=get_open_filename("audio files","level.ogg")
if(_audio!=""&&file_exists(_audio))
{
	songSelected=audio_create_stream(_audio)
}
var _file=get_open_filename("project drumroll files","level.txt")
if(_file!="")
{
	var _loaded=load_file_decode(_file)
	if(_loaded!=false)
	{
		bpm=_loaded.dbpm
		for(var i=0;i<array_length(_loaded.eventy);i++)
		{
			array_push(notes,create_note(_loaded.eventy[i][0],_loaded.eventy[i][1],0))
		}
	}
}
room_goto(rm_play)