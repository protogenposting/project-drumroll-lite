/// @description Insert description here
// You can write your code in this editor
draw_text(room_width/2,0,"combo "+string(combo))
draw_text(room_width/2,16,"score "+string(totalScore))
draw_text(room_width/2,32,"misses "+string(misses))
draw_set_halign(fa_center)
draw_text(room_width/2,room_height-128,rating)
draw_text(room_width/2,room_height-128-16,string(scoreFromLastHit))
var lanePositions=[]
var _x=room_width/2-((laneNumber)/2)*64 + 32
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
if(censorTime>0)
{
	draw_set_alpha(censorTime/censorMax)
	draw_rectangle(0,0,room_width,room_height,true)
	draw_set_alpha(1)
}