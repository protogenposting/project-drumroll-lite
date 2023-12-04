/// @description Insert description here
// You can write your code in this editor
draw_text(0,0,combo)
var lanePositions=[]
var _x=room_width/2-(laneNumber*64)/2
for(var i=0;i<laneNumber;i++)
{
	array_push(lanePositions,_x)
	var _y=room_height-64
	var beatPixelSize=room_height/beatRange
	draw_sprite_ext(spr_note,0,_x,room_height-64+(keyboard_check(global.lanekeys[i])*8),1,1,0,c_white,1)
	draw_line(_x,_y-beatPixelSize*leniency,_x,_y+beatPixelSize*leniency)
	_x+=64
}
for(var i=0;i<array_length(shownNotes);i++)
{
	var _y=((barPercentage-notes[shownNotes[i]].beat)/beatRange)*room_height
	draw_sprite(spr_note,0,lanePositions[notes[shownNotes[i]].lane],room_height+_y-64)
}