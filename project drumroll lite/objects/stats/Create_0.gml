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

zoom=1
zoomRate=0

cameraRotation=0
cameraRotateRate=0

censorTime=0
censorMax=0
//play the audio
current_audio=audio_play_sound(editor.songSelected,1000,false)

//get the notes
notes=editor.notes
events=editor.events
shownNotes=[]

//sort notes (original project drumroll has notes out of order)
array_sort(notes,sort_by_beat)

//turn on fullscreen
window_set_fullscreen(true)


//u can change these if u like
laneNumber=4

beatRange=4

leniency=0.2

