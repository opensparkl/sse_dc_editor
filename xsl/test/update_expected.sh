echo Run from inside directory that has correct *.out.xml files.
for f in *.out.xml; do mv $f `echo $f | sed -e 's/out/expected/'` ; done
