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
	cat $(DESIGN)_pg?.ps > $(DESIGN)_schematic.ps
	$(PDF) $(DESIGN)_schematic.ps
	rm -f *.ps

render_front:
	$(PCB) -x png --photo-mode --dpi 450  --use-alpha --only-visible \
     --outfile /tmp/out.png $(DESIGN).pcb
	$(CVT) /tmp/out.png \
		\( +clone -background black -shadow 75x20+20+20 \) \
		+swap  -background white -layers merge -resize 67% $(DESIGN)_front.jpg
	
render_back:
	$(PCB) -x png --photo-mode --dpi 450  --use-alpha --only-visible \
     --photo-flip-x --outfile /tmp/out.png $(DESIGN).pcb
	$(CVT) /tmp/out.png \
		\( +clone -background black -shadow 75x20+20+20 \) \
		+swap  -background white -layers merge -resize 67% $(DESIGN)_back.jpg
	
gerber:
	rm -rf gerbers
	mkdir gerbers
	$(PCB) -x gerber --gerberfile gerbers/$(DESIGN) bcc_s6.pcb

oshpark: bcc_s6.pcb
	$(PCB) -x gerber --gerberfile $(DESIGN) bcc_s6.pcb
	mv $(DESIGN).bottom.gbr $(DESIGN).GBL
	mv $(DESIGN).bottommask.gbr  $(DESIGN).GTS
	mv $(DESIGN).group1.gbr  $(DESIGN).G2L
	mv $(DESIGN).group2.gbr  $(DESIGN).G3L
	mv $(DESIGN).top.gbr  $(DESIGN).GTL
	mv $(DESIGN).topmask.gbr  $(DESIGN).GTS
	mv $(DESIGN).topsilk.gbr  $(DESIGN).GTO
	mv $(DESIGN).outline.gbr  $(DESIGN).GKO
	mv $(DESIGN).plated-drill.cnc  $(DESIGN)_plated.XLN
	mv $(DESIGN).unplated-drill.cnc $(DESIGN)_unplated.XLN
	zip $(DESIGN)_oshpark.zip *.G?? *.XLN
	rm *.G?? *.XLN *.gbr
	