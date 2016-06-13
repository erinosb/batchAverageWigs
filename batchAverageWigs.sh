#!/bin/bash

##################################################################################
#batch_average_wigs.sh
#
# Creative Commons CC0 1.0 License 2016, Erin Osborne Nishimura
#
#VERSION:
#       1
#
#AUTHOR:
#       Erin Osborne Nishimura
#
#DATE:
#       June 13, 2016         
#
#PURPOSE:
#       A very basic wrapper to merge together replicates of wig files by averaging across conditions in batch.
#
#
#USAGE:
#       bash 02_average_bws.sh metafile.txt chromfile.txt
#
#
#INPUT:
#       1) metafile.txt --> a tab-delimited text file (.txt) that lists the replicate bw files and their conditions
#               Example:
#               ../03_OUTPUT/st225_test.bw	ABpl
#               ../03_OUTPUT/st226_test.bw	ABpl
#       2) chromfile.txt --> a chromosome length file
#               Requires chromosome length file. downloaded from: http://hgdownload.cse.ucsc.edu/downloads.html
#               Example, for ce10 c. elegans: http://hgdownload.cse.ucsc.edu/goldenPath/ce10/bigZips/ce10.chrom.sizes
#       3) the .wig files listed in the metafile. These need to be real .wig files. See https://genome.ucsc.edu/goldenpath/help/wiggle.html
#
#
#OUTPUT:
#       NAME_avg.wig -- averaged .wig files
#       NAME_avg.bw -- averaged bw files
#       DATE_avg_bw_tracks.log -- a .txt file of custom track descriptions
#     
#
#EXAMPLE:
#       bash 02_average_bws.sh fixed_metadata_test.txt /proj/dllab/Erin/ce10/from_ucsc/seq/chr_length_ce10.txt
#
#REQUIREMENTS:
#       Requires java-genomics-toolkit available from: https://github.com/timpalpant/java-genomics-toolkit
#       Requires the ucsc genome utility wigToBigWig available: http://hgdownload.soe.ucsc.edu/admin/exe/
#
#
#KNOWN BUGS:
#
#FUTURE EXTENSION:
#       -- Add an option to put the track info in the metadata file.
#
##################################################################################

#Get options
uppath=

for n in $@
do
    case $n in

        -u) shift;
        uppath=$1;
        shift;
        ;;
        esac
    done
    
    

# Get files and conditions
files=($(cut -f 1 $1))
cell=($(cut -f 2 $1))

#Start a track file
DATE=$(date +"%Y-%m-%d_%H%M")
dated_track=${DATE}_avg_bw_tracks.log

#Loop through conditions and
   #loop through conditions and perform java-genomics-toolkit wigmath.Average
#   Convert the final average to .bw



uniqcells=($(printf "%s\n" "${cell[@]}" | sort -u))

for i in ${uniqcells[@]}
do
    #start an array to capture matches to uniqcell
    echo "i is " $i
    matcharray=()
    
    #Loop through all the cell types and pull out all the other files of the same cell type:
    for (( j=0; j< ${#cell[@]}; j++ ))
    do
        if [ ${cell[$j]} = $i ]
        then
            echo "match"
            
            #echo "i is " $i
            #echo "j is " $j
            #echo "element j is " ${cell[$j]}
            #echo "file element is " ${files[$j]}
            inbwfile=${files[$j]}

            matcharray+=($inbwfile)

        fi
    done
    
    #get base directory
    echo "Elmeent match array is" ${matcharray[@]}
    dirname="$(dirname ${matcharray[0]})"
    #dirname=${matcharray[0]%/*}
    echo "dirname is " $dirname
    pathbase=${dirname}"/"${i}
    pathbase=$pathbase"_average.wig"
    echo "pathbase is "$pathbase
    #echo "matcharray is " ${matcharray[@]}
    toolRunner.sh wigmath.Average -o $pathbase -f ${matcharray[@]}
    
    #Compress average.wig to .bw
    echo "compressing: "
    cmd="wigToBigWig $pathbase $2 ${dirname}/${i}_average.bw "
    echo $cmd
    wigToBigWig $pathbase $2 ${dirname}/${i}_average.bw
    
    #Write track file
    #track type=bigWig name="My Big Wig" description="A Graph of Data from My Lab" bigDataUrl=http://myorg.edu/mylab/myBigWig.bw
    description=
    for n in ${matcharray[@]}
    do
        base="$(basename $n)"
        base=${base%%.*}
        description+="_"
        description+="$base"
    done
    
    #Start a 
    echo "track type=bigWig name=\"$i\" description=\"$description\" maxHeightPixels=100:100:11 autoScale=off viewLimits=0:6 visibility=2 color= bigDataUrl=$uppath/${i}_average.bw type=bigWig" | tee -a $dated_track 
    
done
