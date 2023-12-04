/// @description Insert description here
// You can write your code in this editor
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
		#region missing notes
		if(notes[i].beat+leniency<currentBeat)
		{
			misses+=1
			notes[i].hit=true
			combo=0
		}
		#endregion
		#region hitting notes
		if(notes[i].beat<currentBeat+leniency&&notes[i].beat>currentBeat-leniency)
		{
			if(keyboard_check_pressed(global.lanekeys[notes[i].lane])&&!lanesHit[notes[i].lane])
			{
				combo++
				notes[i].hit=true
				lanesHit[notes[i].lane]=true
			}
		}
		#endregion
	}
	i++
}
#endregion