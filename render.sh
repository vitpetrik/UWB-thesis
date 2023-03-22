now=`date +"%Y-%m-%d"`
quarto render thesis.qmd --output "out_$now.pdf" --to pdf
mv "out_$now.pdf" render/"out_$now.pdf"