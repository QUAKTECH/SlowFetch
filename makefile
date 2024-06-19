all: move_slowfetch move_license

move_slowfetch:
		mv slowfetch /usr/bin/

move_license:
		mkdir -p ~/.config/slowfetch/LICENSE/
		mv LICENSE ~/.config/slowfetch/LICENSE/
