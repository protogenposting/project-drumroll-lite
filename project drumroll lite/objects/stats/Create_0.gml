/// @description Setup

//im not exactly sure what formula remap is but it works :)
function remap(value, left1, right1, left2, right2) {
  return left2 + (value - left1) * (right2 - left2) / (right1 - left1);
}

//setting up some stuff
currentBeat=0
beat=0
bpm=editor.bpm
barPercentage=0
misses=0
combo=0
rating=""
totalScore=0
scoreFromLastHit=0
accuracy=[]

zoom=1
zoomRate=0

cameraRotation=0
cameraRotateRate=0

censorTime=0
censorMax=0

//get the notes
notes=editor.notes
events=editor.events
shownNotes=[]

//sort notes (original project drumroll has notes out of order)
array_sort(notes,sort_by_beat)

//turn on fullscreen
//window_set_fullscreen(true)


//u can change these if u like
laneNumber=editor.rows
if(laneNumber==8)
{
	global.lanekeys=global.lanekeys8
}

beatRange=4

leniency=0.2

countdown=3

alarm[0]=(60/bpm)*64

lanePositions=[]
var _x=room_width/2-((laneNumber)/2)*64 + 32
for(var i=0;i<laneNumber;i++)
{
	array_push(lanePositions,_x)
	var _y=room_height-64
	var beatPixelSize=room_height/beatRange
	_x+=64
}