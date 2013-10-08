# Makefile for gEDA/PCB
# 10-08-2013 E. Brombaugh

# base name
DESIGN = bcc_s6

# Executables
GSCH = gschem
GNET = gnetlist
PCB = pcb
PDF = ps2pdf
CVT = convert

# Targets
clean:
	-rm -f *~ *- *.new.pcb *.cmd *.net *.pdf *.jpg bom.txt *.ps

bom:
	$(GNET) -g bom $(DESIGN)_pg?.sch -o bom.txt
	
sch_pdf:
	$(GSCH) -p -o $(DESIGN)_pg1.ps -s print.scm $(DESIGN)_pg1.sch
	$(GSCH) -p -o $(DESIGN)_pg2.ps -s print.scm $(DESIGN)_pg2.sch
	$(GSCH) -p -o $(DESIGN)_pg3.ps -s print.scm $(DESIGN)_pg3.sch
	cat $(DESIGN)_pg?.ps > $(DESIGN).ps
	$(PDF) $(DESIGN).ps
	rm -f *.ps

render_front:
	$(PCB) -x png --photo-mode --dpi 450  --use-alpha --only-visible \
     --outfile /tmp/out.png $(DESIGN).pcb
	$(CVT) /tmp/out.png \
		\( +clone -background black -shadow 75x20+20+20 \) \
		+swap  -background white -layers merge -resize 67% $(DESIGN)_front.jpg
	
