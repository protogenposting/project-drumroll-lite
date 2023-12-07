/// @description Insert description here
// You can write your code in this editor
function draw_ui(){
	if(array_length(accuracy)>0)
	{
		var currentAccuracy=accuracy[0]
		var i=1
		repeat(array_length(accuracy)-1)
		{
			currentAccuracy+=accuracy[i]
			i++
		}
		currentAccuracy/=array_length(accuracy)
		draw_text(room_width/2,48,"accuracy "+string(currentAccuracy)+"%")
	}
	draw_text(room_width/2,0,"combo "+string(combo))
	draw_text(room_width/2,16,"score "+string(totalScore))
	draw_text(room_width/2,32,"misses "+string(misses))
	draw_set_halign(fa_center)
	draw_text(room_width/2,room_height-128,rating)
	draw_text(room_width/2,room_height-128-16,string(scoreFromLastHit))
}
function draw_screen_normal(){
	draw_ui()
	lanePositions=[]
	var _x=room_width/2-((laneNumber)/2)*64 + 32
	for(var i=0;i<laneNumber;i++)
	{
		array_push(lanePositions,[_x,room_height-64])
		var _y=room_height-64
		var beatPixelSize=room_height/beatRange
		draw_sprite_ext(spr_note,0,_x,_y+(keyboard_check(global.lanekeys[i])*8),1,1,0,c_white,1)
		draw_line(_x,_y-beatPixelSize*leniency,_x,_y+beatPixelSize*leniency)
		_x+=64
	}
	for(var i=0;i<array_length(shownNotes);i++)
	{
		var _x=lanePositions[notes[shownNotes[i]].lane][0]
		var _y=((barPercentage-notes[shownNotes[i]].beat)/beatRange)*room_height
		_y=room_height+_y-64
		if(notes[shownNotes[i]].type==0)
		{
			draw_sprite(spr_note,0,_x,_y)
		}
		if(notes[shownNotes[i]].type==1)
		{
			draw_sprite(spr_note_bad,0,_x,_y)
		}
	}
}
function draw_screen_circle(){
	draw_ui()
	lanePositions=[]
	var _y=room_height/2-((laneNumber)/2)*64 + 32
	for(var i=0;i<laneNumber;i++)
	{
		array_push(lanePositions,[room_width/2,_y])
		var _x=room_width/2
		var beatPixelSize=room_height/beatRange
		draw_sprite_ext(spr_note,0,_x+(keyboard_check(global.lanekeys[i])*8),_y,1,1,0,c_white,1)
		draw_line(_x-beatPixelSize*leniency,_y,_x+beatPixelSize*leniency,_y)
		_y+=64
	}
	for(var i=0;i<array_length(shownNotes);i++)
	{
		var isEven=frac(shownNotes[i]/2)==0
		var _x=lanePositions[notes[shownNotes[i]].lane][0]-lengthdir_x((barPercentage-notes[shownNotes[i]].beat)/beatRange*1024,(barPercentage-notes[shownNotes[i]].beat)/beatRange*90-180*isEven)
		var _y=lanePositions[notes[shownNotes[i]].lane][1]-lengthdir_y((barPercentage-notes[shownNotes[i]].beat)/beatRange*1024,(barPercentage-notes[shownNotes[i]].beat)/beatRange*90-180*isEven)
		if(notes[shownNotes[i]].type==0)
		{
			draw_sprite(spr_note,0,_x,_y)
		}
		if(notes[shownNotes[i]].type==1)
		{
			draw_sprite(spr_note_bad,0,_x,_y)
		}
	}
}
function draw_screen_undyne(){
	draw_ui()
	lanePositions=[]
	var _y=room_height/2-((laneNumber)/2)*64 + 32
	for(var i=0;i<laneNumber;i++)
	{
		array_push(lanePositions,[room_width/2,_y])
		var _x=room_width/2
		var beatPixelSize=room_height/beatRange
		draw_sprite_ext(spr_note,0,_x+(keyboard_check(global.lanekeys[i])*8),_y,1,1,0,c_white,1)
		draw_line(_x-beatPixelSize*leniency,_y,_x+beatPixelSize*leniency,_y)
		_y+=64
	}
	for(var i=0;i<array_length(shownNotes);i++)
	{
		var isEven=frac(shownNotes[i]/2)==0
		var _x=lanePositions[notes[shownNotes[i]].lane][0]-((barPercentage-notes[shownNotes[i]].beat)/beatRange)*(room_width-(room_width*2*isEven))
		var _y=lanePositions[notes[shownNotes[i]].lane][1]
		if(notes[shownNotes[i]].type==0)
		{
			draw_sprite(spr_note,0,_x,_y)
		}
		if(notes[shownNotes[i]].type==1)
		{
			draw_sprite(spr_note_bad,0,_x,_y)
		}
	}
}
function draw_screen_flash(){
	draw_ui()
	laneShown++
	if(laneShown>laneNumber-1)
	{
		laneShown=0
	}
	lanePositions=[]
	var _x=room_width/2-((laneNumber)/2)*64 + 32
	for(var i=0;i<laneNumber;i++)
	{
		array_push(lanePositions,[_x,room_height-64])
		var _y=room_height-64
		var beatPixelSize=room_height/beatRange
		if(i==laneShown)
		{
			draw_sprite_ext(spr_note,0,_x,_y+(keyboard_check(global.lanekeys[i])*8),1,1,0,c_white,1)
			draw_line(_x,_y-beatPixelSize*leniency,_x,_y+beatPixelSize*leniency)
		}
		_x+=64
	}
	for(var i=0;i<array_length(shownNotes);i++)
	{
		if(notes[shownNotes[i]].lane!=laneShown)
		{
			continue;
		}
		var offset=-256
		repeat(5)
		{
			var _x=lanePositions[notes[shownNotes[i]].lane][0] + offset + irandom_range(-5,5)
			var _y=((barPercentage-notes[shownNotes[i]].beat)/beatRange)*room_height + offset + irandom_range(-5,5)
			_y=room_height+_y-64
			if(notes[shownNotes[i]].type==0)
			{
				draw_sprite(spr_note,0,_x,_y)
			}
			if(notes[shownNotes[i]].type==1)
			{
				draw_sprite(spr_note_bad,0,_x,_y)
			}
			offset+=128
		}
	}
}
if(drawStyle==0)
{
	draw_screen_normal()
}
if(drawStyle==1)
{
	draw_screen_circle()
}
if(drawStyle==2)
{
	draw_screen_undyne()
}
if(drawStyle==3)
{
	draw_screen_flash()
}


if(censorTime>0)
{
	draw_set_alpha(censorTime/censorMax)
	draw_rectangle(0,0,room_width,room_height,true)
	draw_set_alpha(1)
}