now=`date +"%Y-%m-%d"`
quarto render --to ctu-thesis-pdf
mv "index.pdf" render/"UWB-thesis_$now.pdf"