/// @description Insert description here
// You can write your code in this editor
function remap(value, left1, right1, left2, right2) {
  return left2 + (value - left1) * (right2 - left2) / (right1 - left1);
}
currentBeat=0
beat=0
bpm=editor.bpm
barPercentage=0

current_audio=audio_play_sound(editor.songSelected,1000,false)

notes=editor.notes

array_sort(notes,sort_by_beat)

window_set_fullscreen(true)

laneNumber=4

beatRange=4

leniency=0.2

misses=0

combo=0