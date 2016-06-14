#!/bin/bash

####################################################################################
### batchAverageWigs.sh
#Creative Commons CC0 1.0 License 2016, Erin Osborne Nishimura
#
###### VERSION  
#1
#
###### AUTHOR  
#Erin Osborne Nishimura
#    
###### DATE  
#June 13, 2016         
#
###### PURPOSE  
#A very basic wrapper to merge together replicates of wig files by averaging across conditions in batch.
#
###### USAGE
#```
#./batchAverageWigs [options] metafile.txt chromfile.txt  
    #-M | --Maxview      An option to specify maximum view height in the custom track info. Default is 20.
    #-m | --minview      An option to specify minimum view height in the custom track info. Default is 0.
    #-o | --outpath      An output directory. Default is to sent output to the local directory.
    #-u | --uppath       URL address to provide to UCSC genome browser specifying the ftp/http address of the final .bw file
    #-w | --keepWigs     An option to retain the temporary NAME_avg.wig files. Default will delete these files and retain only .bw files
#```
#
###### INPUT
#```
#1) metafile.txt --> a tab-delimited text file (.txt) that lists the replicate .wig files and their conditions  
#    Example:  
#        ./testfiles/st225_test.wig	ABpl  
#        ./testfiles/st226_test.wig	ABpl  
#2) chromfile.txt --> a chromosome length file  
#    Requires chromosome length file. downloaded from: <http://hgdownload.cse.ucsc.edu/downloads.html>   
#    Example, for ce10 c. elegans: <http://hgdownload.cse.ucsc.edu/goldenPath/ce10/bigZips/ce10.chrom.sizes>  
#3) the .wig files listed in the metafile. These need to be real .wig files. See <https://genome.ucsc.edu/goldenpath/help/wiggle.html>  
#```
#
###### OUTPUT
#```
#1) NAME_avg.bw            -- averaged bw files  
#2) DATE_avg_bw_tracks.log -- a .txt file of custom track descriptions  
#3) NAME_avg.wig           -- averaged .wig files, if -w option is called.
#```
#     
###### EXAMPLE
#```
#./batchAverageWigs.sh -o testfiles/outdir -u http://home/path testfiles/metadata_test.txt testfiles/chr_length_ce10.txt  
#```
#
###### REQUIREMENTS
#Requires [java-genomics-toolkit](https://github.com/timpalpant/java-genomics-toolkit)  
#Requires wigToBigWig that is available as a stand-alone utility in the [UCSC Kent Utilities](http://hgdownload.soe.ucsc.edu/admin/exe/)  
#
###### KNOWN BUGS
#
###### FUTURE EXTENSION
#Add an option to put the track info in the metadata file
#Add an optin for outpath
####################################################################################


#####################  USAGE   ###################################################################

usage="
batchAverageWigs.sh
    A very basic wrapper to merge together replicates of wig files by averaging across conditions in batch.
    Version 1.0; Erin Osborne Nishimura

USAGE
    ./batchAverageWigs.sh [options] metafile.txt chromfile.txt 

OPTIONS
    -M | --Maxview      An option to specify maximum view height in the custom track info. Default is 20.
    -m | --minview      An option to specify minimum view height in the custom track info. Default is 0.
    -o | --outpath      An output directory. Default is to sent output to the local directory.
    -u | --uppath       URL address to provide to UCSC genome browser specifying the ftp/http address of the final .bw file
    -w | --keepWigs     An option to retain the temporary NAME_avg.wig files. Default will delete these files and retain only .bw files


EXAMPLE
    ./batchAverageWigs.sh -o testfiles/outdir -u http://home/path testfiles/metadata_test.txt testfiles/chr_length_ce10.txt 
    
REQUIRES
    Requires [java-genomics-toolkit](https://github.com/timpalpant/java-genomics-toolkit)  
    Requires wigToBigWig that is available as a stand-alone utility in the [UCSC Kent Utilities](http://hgdownload.soe.ucsc.edu/admin/exe/) 
    "
#####################  USAGE   ###################################################################


############################ PRE PROCESSING
#Require input, else die
if [ -z "$1" ]
then
    echo -e "$usage"  
    exit
fi


#Get options
uppath=
keepWigs="FALSE"
Max=20
min=0
outdir="."

for n in $@
do
    case $n in

        -u | --uppath) shift;
        uppath=$1;
        shift;
        ;;
        -w | --keepWigs) shift;
        keepwigs="TRUE";
        ;;
        -M | --Maxview) shift;
        Max=$1;
        shift;
        ;;
        -m | --minview) shift;
        min=$1;
        shift;
        ;;
        -o | --outpath) shift;
        outdir=$1;
        shift;
        ;;
        esac
    done
    

#Require two arguments, else die:    
if [ -z "$2" ]; then
    echo -e "ERROR: Expecting arguments"
    echo -e "$usage"  
    exit
fi

if [ ! -f $1 ]; then
    echo "ERROR: Expecting metadata file. Can't open $1"
    echo -e "$usage"  
    exit
fi

if [ ! -f $2 ]; then
    echo "ERROR: Expecting chromosome length file. Can't open $2"
    echo -e "$usage"  
    exit
fi

#Unless it exists, make an output directory
if [ ! -d $outdir ]; then
    mkdir $outdir
fi


############################
# Get files and conditions
echo "Parsing through the files listed in $1..."
echo "Using the chromosome lengths listed in $2..."
files=($(cut -f 1 $1))
cell=($(cut -f 2 $1))

#Start a track file
DATE=$(date +"%Y-%m-%d_%H%M")
dated_track=${outdir}/${DATE}_avg_bw_tracks.log


############################
#Determine all unique conditions
uniqcells=($(printf "%s\n" "${cell[@]}" | sort -u))


#Loop through conditions and perform java-genomics-toolkit wigmath.Average on all matching files
#   Convert the final average to .bw
for i in ${uniqcells[@]}
do
    #start an array to capture matches to uniqcell
    echo "Processing condition $i..."
    matcharray=()
    
    #Loop through all the cell types and pull out all the other files of the same cell type:
    for (( j=0; j< ${#cell[@]}; j++ ))
    do
        if [ ${cell[$j]} = $i ]
        then
            echo -e "\t${files[$j]} is a replicate of condition $i"
            inbwfile=${files[$j]}

            matcharray+=($inbwfile)

        fi
    done
    
    #Set the name of the averaged output file:
    pathbase=${outdir}"/"${i}
    pathbase=$pathbase"_avg.wig"
    
    #Perform wigmath.Average
    echo "Averaging files from ${matcharray[@]} into $pathbase..."
    cmd1="toolRunner.sh wigmath.Average -o $pathbase -f ${matcharray[@]}"
    echo -e "\t$cmd1"
    $cmd1
    
    #Compress average.wig to .bw
    echo "Compressing .wig to .bw file..."
    cmd2="wigToBigWig $pathbase $2 ${outdir}/${i}_avg.bw "
    echo -e "\t$cmd2"
    $cmd2
    
    #Gather information for a trackfile
    description=
    for n in ${matcharray[@]}
    do
        base="$(basename $n)"
        base=${base%%.*}
        description+="_"
        description+="$base"
    done
    
    #Set trackfile info
    description=${description/#_/}
    urlinfo="bigDataUrl=$uppath/${i}_avg.bw"
    
    #Write a trackfile
    echo "Writing trackfile..."
    echo "track type=bigWig name=\"$i\" description=\"$description\" maxHeightPixels=100:100:11 autoScale=off viewLimits=${min}:${Max} visibility=2 color=0,0,255 $urlinfo type=bigWig" | tee -a $dated_track 
    
    #Remove .wig files unless specified
    if [ keepWigs = "FALSE" ]
    then
        echo "REMOVING temporary .wig file..."
        rm ${outdir}/${i}_avg.wig
    fi
    
    #Clean up temp files
    for n in ${matcharray[@]}
    do
        rm ${n}.idx
    done
    
done



