now=`date +"%Y-%m-%d"`
quarto render UWB-thesis.qmd --to ctu-thesis-pdf --output "UWB-thesis_$now.pdf"
mv "UWB-thesis_$now.pdf" render/"UWB-thesis_$now.pdf"