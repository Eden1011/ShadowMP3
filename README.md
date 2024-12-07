# ShadowMP3
### Lightweight, minimalistic media player for the CLI via YouTube API.
**ShadowMP3** uses the Google Cloud YouTube API to play media 
from the site, save tracks (as links) and display thumbnails, all inside the Linux terminal. 
It is highly customizable (just a single shell script), and provides thorough code comments for DYI tinkering.

You can get your own API key from: https://cloud.google.com/apis

The necessary **dependencies** for ShadowMP3 are: `jq`, `mpv`, `catimg`.  

### How to build ShadowMP3
Clone the repository
```bash
git clone https://github.com/Eden1011/ShadowMP3.git ~/ShadowMP3
```
Add executable permissions for the script.
```bash
chmod +x ~/ShadowMP3/shadowmp3.sh
```
Add installed directory into `PATH` variable. This step will let you call the
script from anywhere on your computer.
```bash
echo "export PATH=$PATH:/home/your_user_name/ShadowMP3" >> ~/.bashrc
```
Alias file as `shadowmp3` for ease of use.
```bash
echo 'alias shadowmp3="shadowmp3.sh"' >> ~/.bashrc
```
### In detail about ShadowMP3
This program, by default, does not play YouTube videos, only audio (but this can be changed).
```bash
mpv --no-video --loop-file=yes
```
All files, are put on a loop, for the user to 'cancel' out of, which prompts the user
whether they'd like to save the track into memory.

All data saved is inside the `~/.shadowmp3` directory, which contains the two main files:
- api_key - is where the API key is stored,
- library - where track's names and URLs are stored.

### Using ShadowMP3
Firstly, input your private API key into the program by using:
```bash
shadowmp3 API_KEY=your_api_key
```
**SEARCH**: To search for videos, write:
```bash
shadowmp3 "name of your video" amount_of_query_results
```
Note that if the amount of results is not specified, it is set to `5`.

**SAVE**: To save a track, use:
```bash
shadowmp3 track_name=track_link
```
**PULL**: To pull a saved track from the `library`, prefix it's with a `@` like so:
```bash
shadowmp3 @track_name
``` 
Please note, that `@track_name` has to match the whole word for compatibility reasons, because having more than
one track with the same name results in a pull conflict (the user is notified when such occurs).
### Choosing from a query input
After a successful query, the program will show you a list of available tracks to play:
```text
Please pick from result(s):
1) Music 4 -- "Duran Duran - INVISIBLE"                                   4) Yoda -- "Duran Duran - invisible Metal Gear Version"
2) Duran Duran -- "Duran Duran - INVISIBLE (Official Music Video)"        5) •weoncharie• -- "Invisible (Duran Duran) - Metal Gear Solid V: The Phantom Pain (Original Soundtrack)"
3) Rainbow Sound -- "Duran Duran - INVISIBLE  (Lyrics)"                   6) Quit
Enter your choice (1..6): >
```
After choosing your preffered title, `catimg` will show a preview of the thumbnail, and `mpv` will play the audio.
### Exiting from ShadowMP3 during playing
If the user is to terminate (CTRL^C) the program while it is playing, they will be asked whether or not to save the track
to the `library`.
```text
Would you like to save this track to library? (y/n|q): > y
What name would you like this track to be saved under? (avoid spaces): > "duran"
Successfully saved item "duran".
```
