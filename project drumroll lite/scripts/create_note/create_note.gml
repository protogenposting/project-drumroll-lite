
function create_note(beat,lane,type){
	var note={}
	note.beat=beat
	note.lane=lane
	note.type=type
	note.hit=false
	return note
}