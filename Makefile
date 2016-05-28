build: lint_stylus build_stylus build_elm

build_stylus:
		stylus -p src/styles/index.styl > public/styles.css

lint_stylus:
		stylint

build_elm:
		elm make src/Main.elm --warn --output public/elm.js

all: build_elm

open:
		open public/index.html

debug:
		elm-reactor
