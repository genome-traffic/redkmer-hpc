for i in ./*bash; do
    #phi to niki
    #sed -i 's/\-o \/work\/ppapatha\//\-o \/work\/nikiwind\//g' $i
    #sed -i 's/\-e \/work\/ppapatha\//\-e \/work\/nikiwind\//g' $i
    
    #niki to phi
    sed -i 's/\-o \/work\/nikiwind\//\-o \/work\/ppapatha\//g' $i
    sed -i 's/\-e \/work\/nikiwind\//\-e \/work\/ppapatha\//g' $i 
done
