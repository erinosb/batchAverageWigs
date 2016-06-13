# batchAverageWigs

Creative Commons CC0 1.0 License 2016, Erin Osborne Nishimura

**VERSION:**  
    1

**AUTHOR:**  
    Erin Osborne Nishimura
    
*DATE:*
    June 13, 2016         

*PURPOSE:*
       A very basic wrapper to merge together replicates of wig files by averaging across conditions in batch.

USAGE:
       ./batchAverageWigs [options] metafile.txt chromfile.txt
            -u | --uppath       URL address to provide to UCSC genome browser specifying the ftp/http address of the final .bw file
            -w | --keepWigs     An option to retain the temporary NAME_avg.wig files. Default will delete these files and retain only .bw files

INPUT:
       1) metafile.txt --> a tab-delimited text file (.txt) that lists the replicate .wig files and their conditions
               Example:
               ../03_OUTPUT/st225_test.wig	ABpl
               ../03_OUTPUT/st226_test.wig	ABpl
       2) chromfile.txt --> a chromosome length file
               Requires chromosome length file. downloaded from: http://hgdownload.cse.ucsc.edu/downloads.html
               Example, for ce10 c. elegans: http://hgdownload.cse.ucsc.edu/goldenPath/ce10/bigZips/ce10.chrom.sizes
       3) the .wig files listed in the metafile. These need to be real .wig files. See https://genome.ucsc.edu/goldenpath/help/wiggle.html

OUTPUT:
       NAME_avg.wig -- averaged .wig files
       NAME_avg.bw -- averaged bw files
       DATE_avg_bw_tracks.log -- a .txt file of custom track descriptions
     
EXAMPLE:
       bash 02_average_bws.sh fixed_metadata_test.txt /proj/dllab/Erin/ce10/from_ucsc/seq/chr_length_ce10.txt

REQUIREMENTS:
       Requires java-genomics-toolkit available from: https://github.com/timpalpant/java-genomics-toolkit
       Requires the ucsc genome utility wigToBigWig available: http://hgdownload.soe.ucsc.edu/admin/exe/

KNOWN BUGS:

FUTURE EXTENSION:
       -- Add an option to put the track info in the metadata file

