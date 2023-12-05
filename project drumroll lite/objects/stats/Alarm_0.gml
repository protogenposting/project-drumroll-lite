/// @description Insert description here
// You can write your code in this editor
var coundownSounds=[snd_count_go,snd_count_1,snd_count_2,snd_count_3]
audio_play_sound(coundownSounds[countdown],1000,false)
countdown--
if(countdown<0)
{
	current_audio=audio_play_sound(editor.songSelected,1000,false)
}
else
{
	alarm[0]=(60/bpm)*4
}