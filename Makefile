FILTERS = --filter pandoc-plantuml-filter --filter pandoc-crossref --filter pandoc-citeproc

all: clean build

clean:
	-rm ./output/livro.pdf 

build: 
	pandoc -s \
	-o ./output/livro.pdf \
	--data-dir=. \
	--listings \
	--pdf-engine=xelatex \
	--top-level-division=chapter \
	--number-sections \
	$(FILTERS) \
	 --template ./controls/default.latex \
	./core/*.md \
	./settings/*.yaml \
	./metadata/*.yaml
