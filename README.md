# Scripts
Mostly bash scripts.
Some of them will remove your files if you run them which isn't my problem!

[search_scripts.sh](search_scripts.sh) - Uses fzf to find and run these scripts. I guess you can do aliases but I prefer this.
Most of the scripts take input from prompt but some require arguments so you would need to run the directly.

## Working with files
### Converting
- [convert_to_jpg.sh](convert_to_jpg.sh) - Uses `convert` [ImageMagick](https://imagemagick.org/script/convert.php) to convert from different formats into `.jpg`. Keeps the same name and removes old files.
- [webp_to_jpg.sh](webp_to_jpg.sh) - Converts `.webp` to `.jpg`. Superseded by the one above.
- [rename_random.sh](rename_random.sh) - Renames files in the current dir to random.

### Moving files
- [organize_downloads.sh](organize_downloads.sh) - Creates dirs in `~/Downloads` and moves files based on their type to those dirs

### Project templates
- [python_project.sh](python_project.sh) - Creates python project - creates .venv and activates it, gets .gitignore from github, pyright fix for nvim
- [website_project.sh](website_project.sh) - Creates simple folder structure for a web project - single `index.html`, `main.js` and some `.css` files

## Online stuff
### Getting data
- [cht.sh](cht.sh) - Gets the data from https://cht.sh
- [ip_info.sh](ip_info.sh) - Some basic network data - ip, location, ISP,...
- [weather.sh](weather.sh) - Gets the weather data for a given city from https://wttr.in/

### Sending data
- [todoist.sh](todoist.sh) - Add tasks to todoist. If I don't add something within 20 sec I will probably forget it, and this is a fast way to do it.
- [upload_file.sh](upload_file.sh) - Uploads given file to whatever service allows it atm and shows link and QR code for the file.
- [ntfy.sh](ntfy.sh) - Uses https://ntfy.sh/ to basically send notifications to my phone 

## Productivity?
- [obsidian_append.sh](obsidian_append.sh) - appends given text as a task to a markdown(in this case [Obsidian](https://obsidian.md/)) file.
- [tmux_session.sh](tmux_session.sh) - Creates tmux session and populates it windows
- [backup_hdd.sh](backup_hdd.sh) - uses `rsync` to backup data to another hdd and to external hdd. Mounts them if they are connected and not mounted.

## AI chat
- [mistral_openrouter.sh](mistral_openrouter.sh) - Uses Mistral 7b via [OpenRouter](https://openrouter.ai/). Prompt provided as arg `./mistral_openrouter.sh "Tell me a joke"`

