/// @description Insert description here
// You can write your code in this editor
var barperlast=barPercentage
var beatlen=60/bpm
var needle = audio_sound_get_track_position(current_audio)//+menuobj.offset;
var left = beat * beatlen;
var right = left + beatlen;
barPercentage = remap(needle, left, right, 0, 1);
if(frac(barPercentage)<frac(barperlast))
{
	
}
currentBeat=(barPercentage+beat)

shownNotes=[]
var i=0
var _maxBeat=barPercentage-beatRange
var lanesHit=[]
repeat(laneNumber)
{
	array_push(lanesHit,false)
}
repeat(array_length(notes))
{
	if(!notes[i].hit)
	{
		if(notes[i].beat>_maxBeat&&notes[i].beat+leniency>currentBeat)
		{
			array_push(shownNotes,i)
		}
		if(notes[i].beat+leniency<currentBeat)
		{
			misses+=1
			notes[i].hit=true
			//combo++
		}
		if(notes[i].beat<currentBeat+leniency&&notes[i].beat>currentBeat-leniency)
		{
			if(keyboard_check_pressed(global.lanekeys[notes[i].lane])&&!lanesHit[notes[i].lane])
			{
				combo++
				notes[i].hit=true
				lanesHit[notes[i].lane]=true
			}
		}
	}
	i++
}