all: index.html

index.html:
	elm-make gol.elm

clean:
	rm -rf index.html
