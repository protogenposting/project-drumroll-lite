// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function save_file(struct,fname){
	var _saveData = struct
	var _string = json_stringify(_saveData)
	var _buffer = buffer_create(string_byte_length(_string)+1, buffer_fixed,1)
	buffer_write(_buffer, buffer_string,_string)
	buffer_save(_buffer,fname)
	buffer_delete(_buffer)
	
	show_debug_message("game saved! "+_string)
}