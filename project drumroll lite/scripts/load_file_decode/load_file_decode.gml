// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function load_file_decode(fname){
	show_debug_message("loading save...")
	if(file_exists(fname))
	{
		var _buffer = buffer_load(fname)
		var _string = buffer_read(_buffer,buffer_string)
		buffer_delete(_buffer)
		
		_string=base64_decode(_string)
		var _loadData = json_parse(_string)
		show_debug_message("game LOADED DIAPER! "+string(_loadData))
		return _loadData;
	}
	else
	{
		return false;
	}
}