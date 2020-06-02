.PHONY: all FORCE clean
all: $(wildcard pg*.html)

pg%.html: FORCE
	@./start.sh $@

clean:
	@rm -f *.span.txt *.html.temp

FORCE:;