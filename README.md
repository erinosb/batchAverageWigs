# batchAverageWigs

MIT License 2016, Erin Osborne Nishimura

##### VERSION  
1

##### AUTHOR  
Erin Osborne Nishimura
    
##### DATE  
June 13, 2016         

##### PURPOSE  
A very basic wrapper to merge together replicates of wig files by averaging across conditions in batch. Does the following...
  1. Merges .wig files into an average .wig file
  2. Comparesses the .wig file into a .bw file
  3. Writes a track log file that contains custom track information for uploading to UCSC Genome browser

##### USAGE
```
./batchAverageWigs [options] metafile.txt chromfile.txt  
    -M | --Maxview      An option to specify maximum view height in the custom track info. Default is 20.
    -m | --minview      An option to specify minimum view height in the custom track info. Default is 0.
    -o | --outpath      An output directory. Default is to sent output to the local directory.
    -u | --uppath       URL address to provide to UCSC genome browser specifying the ftp/http address of the final .bw file
    -w | --keepWigs     An option to retain the temporary NAME_avg.wig files. Default will delete these files and retain only .bw files
```

##### INPUT
```
1) metafile.txt --> a tab-delimited text file (.txt) that lists the replicate .wig files and their conditions  
    Example:  
        ./testfiles/st225_test.wig	ABpl  
        ./testfiles/st226_test.wig	ABpl  
2) chromfile.txt --> a chromosome length file  
    Requires chromosome length file. downloaded from: <http://hgdownload.cse.ucsc.edu/downloads.html>   
    Example, for ce10 c. elegans: <http://hgdownload.cse.ucsc.edu/goldenPath/ce10/bigZips/ce10.chrom.sizes>  
3) the .wig files listed in the metafile. These need to be real .wig files. See <https://genome.ucsc.edu/goldenpath/help/wiggle.html>  
```

##### OUTPUT
```
1) NAME_avg.bw            -- averaged bw files  
2) DATE_avg_bw_tracks.log -- a .txt file of custom track descriptions  
3) NAME_avg.wig           -- averaged .wig files, if -w option is called.
```
     
##### EXAMPLE
```
./batchAverageWigs.sh -o testfiles/outdir -u http://home/path testfiles/metadata_test.txt testfiles/chr_length_ce10.txt 
```

##### REQUIREMENTS
Requires [java-genomics-toolkit](https://github.com/timpalpant/java-genomics-toolkit)  
Requires wigToBigWig that is available as a stand-alone utility in the [UCSC Kent Utilities](http://hgdownload.soe.ucsc.edu/admin/exe/)

##### TESTING
To test batchAverageWigs.sh, execute the following code from within the main directory:
```
./batchAverageWigs.sh -o testfiles/outdir -u http://home/path testfiles/metadata_test.txt testfiles/chr_length_ce10.txt 
```
Check that the contents of testfiles/outdir match the content of testfiles/reference. The date on the logfiles is different, but the content of the files should be the same.

##### KNOWN BUGS

##### FUTURE EXTENSION
Add an option to put additional track info in the metadata file

