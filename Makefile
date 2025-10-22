AWMAKER = ../../awmaker/convertor/awmakerc.exe

all: NGCIC.pdb RedNGCIC.pdb SAC.pdb RedSAC.pdb

Distances.txt: GetDistance.pl
	perl GetDistance.pl > Distances.txt

RedNGCIC.tab: Barnard.csv NI2008.txt ConversionScript.pl Distances.txt
	perl ConversionScript.pl red < NI2008.txt > RedNGCIC.tab

SAC.tab: SAC_DeepSky_Ver80_QCQ.txt SAC.pl Distances.txt
	perl SAC.pl < SAC_DeepSky_Ver80_QCQ.txt > SAC.tab

RedSAC.tab: SAC_DeepSky_Ver80_QCQ.txt SAC.pl Distances.txt
	perl SAC.pl red < SAC_DeepSky_Ver80_QCQ.txt > RedSAC.tab

NGCIC.tab: Barnard.csv NI2008.txt ConversionScript.pl Distances.txt
	perl ConversionScript.pl < NI2008.txt > NGCIC.tab

NGCIC.pdb: NGCIC.tab rngcicabout.txt rngcicabbr.txt
	$(AWMAKER) --pictures_db=NGCICPics --infile=NGCIC.tab --id=NGCIC --trialdays=0 --outfile="NGCIC.pdb" --aboutfile=rngcicabout.txt --source_language=English --allow_html=1 --abbrfile=rngcicabbr.txt

SAC.pdb: SAC.tab sacabout.txt sacabbr.txt
	$(AWMAKER) --infile=SAC.tab --id=SAC --trialdays=0 --outfile="SAC.pdb" --aboutfile=sacabout.txt --source_language=English --allow_html=1 --abbrfile=sacabbr.txt

RedSAC.pdb: RedSAC.tab sacabout.txt sacabbr.txt
	$(AWMAKER) --infile=RedSAC.tab --id=RedSAC --trialdays=0 --outfile="RedSAC.pdb" --aboutfile=sacabout.txt --source_language=English --allow_html=1 --abbrfile=sacabbr.txt

RedNGCIC.pdb: RedNGCIC.tab rngcicabout.txt rngcicabbr.txt
	$(AWMAKER) --pictures_db=NGCICPics --infile=RedNGCIC.tab --id=RedNGCIC --trialdays=0 --outfile="RedNGCIC.pdb" --aboutfile=rngcicabout.txt --source_language=English --allow_html=1 --abbrfile=rngcicabbr.txt

