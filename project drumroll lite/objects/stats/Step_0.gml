/// @description Insert description here
// You can write your code in this editor
if(countdown<0)
{
	if(!audio_is_playing(editor.songSelected))
	{
		current_audio=audio_play_sound(editor.songSelected,1000,false)
	}
	#region get the current beat
	var barperlast=barPercentage
	var beatlen=60/bpm
	var needle = audio_sound_get_track_position(current_audio)//+menuobj.offset;
	var left = beat * beatlen;
	var right = left + beatlen;
	barPercentage = remap(needle, left, right, 0, 1);
	if(frac(barPercentage)<frac(barperlast))
	{
		//actions done every beat go here
	}
	currentBeat=(barPercentage+beat)
	#endregion

	#region get notes on screen and hit them.
	shownNotes=[]

	//reset the lanes hit
	var lanesHit=[]
	repeat(laneNumber)
	{
		array_push(lanesHit,false)
	}

	var i=0
	var _maxBeat=barPercentage+beatRange
	repeat(array_length(notes))
	{
		if(!notes[i].hit) //detect if current note was hit
		{
			//if note is in the range, add it to the shownNotes list
			if(notes[i].beat>currentBeat&&notes[i].beat<_maxBeat)
			{
				array_push(shownNotes,i)
			}
			#region missing notes
			if(notes[i].beat+leniency<currentBeat)
			{
				if(notes[i].type==0)
				{
					misses+=1
					notes[i].hit=true
					combo=0
					array_push(accuracy,0)
				}
			}
			#endregion
			#region hitting notes
			if(notes[i].beat<currentBeat+leniency&&notes[i].beat>currentBeat-leniency)
			{
				var scoreFromHit=105-abs(currentBeat-notes[i].beat)*100
				if(notes[i].type==0)
				{
					if(keyboard_check_pressed(global.lanekeys[notes[i].lane])&&!lanesHit[notes[i].lane]||editor.botplay&&scoreFromHit>=100)
					{
						audio_play_sound(snd_hitsound,1000,false)
						combo++
						notes[i].hit=true
						lanesHit[notes[i].lane]=true
						scoreFromLastHit=scoreFromHit
						totalScore+=scoreFromHit
						if(scoreFromHit<50)
						{
							rating="Offbeat"
						}
						if(scoreFromHit>=50)
						{
							rating="Decent"
						}
						if(scoreFromHit>=80)
						{
							rating="Good"
						}
						if(scoreFromHit>=90)
						{
							rating="Great!"
						}
						if(scoreFromHit>=100)
						{
							rating="Amazing!"
							var p=part_system_create(prt_hit_normal)
							part_system_position(p,lanePositions[notes[i].lane][0],lanePositions[notes[i].lane][1])
						}
						else
						{
							var p=part_system_create(prt_hit_good)
							part_system_position(p,lanePositions[notes[i].lane][0],lanePositions[notes[i].lane][1])
						}
						array_push(accuracy,scoreFromHit)
					}
				}
				if(notes[i].type==1)
				{
					if(keyboard_check_pressed(global.lanekeys[notes[i].lane])/*&&!lanesHit[notes[i].lane]||editor.botplay&&scoreFromHit>=100 uncomment this and remove this text to allow this note to be hit in botplay*/)
					{
						misses+=1
						notes[i].hit=true
						combo=0
					}
				}
			}
			#endregion
		}
		i++
	}

	var laneHitNum=0
	for(var i=0;i<array_length(lanesHit);i++)
	{
		laneHitNum+=lanesHit[i]
	}

	if(laneHitNum>0)
	{
		for(var i=0;i<laneNumber;i++)
		{
			if(!lanesHit[i]&&keyboard_check_pressed(global.lanekeys[i]))
			{
				array_push(accuracy,50)
			}
		}
	}
	#endregion

	#region events
	var defaultWidth=1366
	var defaultHeight=768
	var zoomPercentage=zoom/100
	camera_set_view_pos(view_camera[0],0,0)
	camera_set_view_size(view_camera[0],defaultWidth-(defaultWidth*zoomPercentage),defaultHeight-(defaultHeight*zoomPercentage))
	camera_set_view_pos(view_camera[0],camera_get_view_x(view_camera[0])+((defaultWidth*zoomPercentage)/2),camera_get_view_y(view_camera[0])+((defaultHeight*zoomPercentage)/2))
	camera_set_view_angle(view_camera[0],cameraRotation)

	if(abs(cameraRotation)>0)
	{
		cameraRotation-=cameraRotateRate*sign(cameraRotation)
	}
	if(abs(zoom)>0)
	{
		zoom-=zoomRate*sign(zoom)
	}
	censorTime--

	for(var int=0;int<array_length(events);int++)
	{
		if(currentBeat>=events[int][0]&&!events[int][2])
		{
			if(events[int][1]==0)
			{
				zoom=events[int][3]
				zoomRate=events[int][4]
			}
			if(events[int][1]==1)
			{
				cameraRotation=events[int][3]*events[int][4]
				cameraRotateRate=events[int][5]
			}
			if(events[int][1]==2)
			{
				censorTime=events[int][3]*beatlen
				censorMax=events[int][3]*beatlen
			}
			if(events[int][1]==3)
			{
				drawStyle=events[int][3]*beatlen
				show_message(drawStyle)
			}
			events[int][2]=true
		}
	}

	#endregion

}
else
{
	shownNotes=[]
	currentBeat=-countdown
	var i=0
	var _maxBeat=barPercentage-beatRange
	repeat(array_length(notes))
	{
		if(!notes[i].hit) //detect if current note was hit
		{
			//if note is in the range, add it to the shownNotes list
			if(notes[i].beat>_maxBeat&&notes[i].beat+leniency>currentBeat)
			{
				array_push(shownNotes,i)
			}
		}
		
	}
}