/// @function                create_note(beat,lane,type)
/// @description             Creates a note and returns the note's struct
/// @param {Real}     beat   The beat to hit the note at
/// @param {Real}     lane   The lane the note comes in at
/// @param {Real}     type   The type of note (unused)
/// @return {Note}

function create_note(beat,lane,type){
	var note={}
	note.beat=beat
	note.lane=lane
	note.type=type
	note.hit=false
	return note
}