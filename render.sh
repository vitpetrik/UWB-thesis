now=`date +"%Y-%m-%d"`
quarto render thesis.qmd --output "thesis_$now.pdf"
mv "thesis_$now.pdf" render/"thesis_$now.pdf"