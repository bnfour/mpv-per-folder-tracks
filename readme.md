# mpv-per-folder-tracks
A little script for the [mpv](https://mpv.io/) to set preferred audio and subtitles for a folder of video files at once.

## Installation
Drop `per-folder-tracks.lua` into your [scripts folder](https://mpv.io/manual/stable/#script-location).

## Usage
### Setting the tracks settings
Press `y` (default, configurable) to write current audio and subtitles settings to a file `.mpv` (default, configurable) located in the folder with the currently playing video.  
If you wish to change these settings, these are set at the top of the script -- the very first assignment statements.
### Applying the tracks settings
If the file is present, previously set tracks will be restored for any video file from the same folder, if these exists. Please note that matching is done only by number as it appears in the player UI, not by track name, language, or anything else.
### Explanation and demo
Let's suppose that for some reason there is a folder, where several video files are stored. These files _all_ have multiple audio and subtitle tracks, with same languages having same track IDs.  
Let's suppose that we want to play these files with non-default audio and subtitle tracks. With this handy script, you can open one of these files, change the tracks once, hit `y` (default) to save configuration. You can enjoy the video files without ever having to switch "Signs&Songs" to "Full" again (for this folder).  
| Before | After configuring once for the entire folder |
| -- | -- |
| ![meh](demo/before.png) | ![now we're talking](demo/after.png) |
| not pictured: dub | not pictured: glorious original audio |

The original video files are not modified in any way. To remove track preselection, simply remove the file created by the script.

## Limitations
This is a quick and dirty script to automate my own tedious clicking, so be aware of the following:
* It is only tested on local files on GNU/Linux.  
_(I don't know whether or not will it work with other video types and/or operating systems.)_
* It only provides a way to set audio and/or subtitle tracks with little to none error proofing.  
_(It is not a tool to store any other setting for the player. The filename may be misleading, but i couldn't come up with a better one. See script's comments for some of the shortcomings.)_

Basically, works on my machine. Have fun.

## License
MIT
