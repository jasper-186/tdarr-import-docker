#!/bin/bash

# Dependencies
# mediainfo

PlexDir="/TVShows/"
TdarrDir="/Tdarr/"

files=("1")
#use while to handle whitespace correctly
read -d $'\0' file < <(find $TdarrDir -path */.grab -prune -false -o -iname "*.mkv" -print0)
echo "$file"
while [[ "$file" != "" ]]
do
    #skip Season 01
    if [[ "$file" == *"Bob's Burgers (2011)\Season 01"* ]]
    then
    remove "$file"
    file=''
    read -d $'\0' file < <(find $TdarrDir -path */.grab -prune -false -o -iname "*.mkv" -print0)
    continue;
    fi

    # Season 02 skip
    if [[ "$file" == *"Bob's Burgers (2011)\Season 02"* ]]
    then
    remove "$file"		
    file=''
    read -d $'\0' file < <(find $TdarrDir -path */.grab -prune -false -o -iname "*.mkv" -print0)
    continue;
    fi

    # skip Season 03
    if [[ "$file" == *"Bob's Burgers (2011)\Season 03"* ]]
    then
    remove "$file"
    file=''
    read -d $'\0' file < <(find $TdarrDir -path */.grab -prune -false -o -iname "*.mkv" -print0)
    continue;
    fi 

    # Skip Season 04
    if [[ "$file" == *"Bob's Burgers (2011)\Season 04"* ]]
    then
    remove "$file"
    file=''
    read -d $'\0' file < <(find $TdarrDir -path */.grab -prune -false -o -iname "*.mkv" -print0)
    continue;
    fi

############################################### Start Copy/Move ###############################
    # Cool file Exists, does it also exist on W/R?
    echo "processing file '$file'"
    WrMkvFile="${file//$TdarrDir/$PlexDir}"
    WrMkvFile="${WrMkvFile// .mkv/.mkv}"
    #echo "trimmed file '$WrMkvFile'"

    WrMpFile="${WrMkvFile//.mkv/.mp4}";
    #echo "mp4 file '$WrMpFile'"
    
    WrMvFile="${WrMkvFile//.mkv/.m4v}"
    #echo "m4v file '$WrMvFile'"
    
    # Get the file size so we can check if its better worse
    transcodedFileSize=$(wc -c "$file" | awk '{print $1}')
    buffer=1.1
    if [ -f "$WrMkvFile" ]
    then
    # The mkv File Exists
    echo "Mockturtle Mkv Exists; Checking File Size/Codec"
    WpFileSize=$(wc -c "$WrMkvFile" | awk '{print $1}')
    bufferSize=$(echo "scale=0; ($buffer*$WpFileSize)/1" |bc)
    echo "transcodedFileSize: $transcodedFileSize"
    echo "origFileSize(+10\%):$bufferSize"
    oldFileCodec=$(mediainfo "$file" | grep HEVC)
    # if the file isnt HEVC, oldFileCodec should be empty
    if [ ! "$oldFileCodec" ]
    then
        echo "Old File is not HEVC, overriding check to replace;"
        #Remove original File
        echo "removing old file"
        rm "$WrMkvFile"
        
        echo "Coping New File"
        cp "$file" "$WrMkvFile"
        if [ $? -eq 0 ]
        then
        # copy complete, remove the original TS
        echo "removing recording '$file'"
        # remove the old file
        rm "$file"					
        fi		
    elif [[ $transcodedFileSize -gt $bufferSize ]]
    then
        echo "New File is bigger;"
        #Remove original File
        echo "removing old file"
        rm "$WrMkvFile"
        
        # The New File is substantially	bigger then the Old
        # Because this is mv4 vs mp4 they can exist side-by-side, so remove after copy
        echo "Coping New File"
        cp "$file" "$WrMkvFile"
        if [ $? -eq 0 ]
        then
        # copy complete, remove the original TS
        echo "removing recording '$file'"
        # remove the old file
        rm "$file"					
        fi
    else
        # Old File is Larger, remove new recording
        echo "Old File is bigger;"
        echo "removing recording '$file'"
        rm "$file"
    fi
    elif [ -f "$WrMvFile" ]
    then
    # The m4v File Exists
    echo "Mockturtle M4v Exists; replacing with H265 encoded file"
    # The New MKV is encoded to H265, which will make it smaller then the H264 codec
    echo "removing old file"
    rm "$WrMvFile"
    
    echo "Coping New File"
    cp "$file" "$WrMkvFile"
    if [ $? -eq 0 ]
    then
        # copy complete, remove the original TS
        echo "removing recording '$file'"
        # remove the old file
        rm "$file"
    fi
    
    elif [ -f "$WrMpFile" ]
    then
    # The mp4 File Exists
    echo "Mockturtle Mp4 Exists; replacing with H265 encoded file"
    
    # The New MKV is encoded to H265, which will make it smaller then the H264 codec
    echo "removing old file"
    rm "$WrMpFile"
    
    echo "Coping New File"
    cp "$file" "$WrMkvFile"
    if [ $? -eq 0 ]
    then
        # copy complete, remove the original TS
        echo "removing recording '$file'"
        rm "$file"
    fi
    elif [ -d "$WrMkvFile" ]
    then
    # We made a mistake here, and accidentially name a directory the file name, and put the file inside that
    parentDir=$(dirname "$WrMkvFile")
    
    # rename the directory to temp
    mv "$WrMkvFile" "$parentDir/temp"
    # Copy the contents into the parent dir
    mv "$parentDir/temp/*" "$parentDir/"
    # remove the temp dir
    rmdir "$parentDir/temp"
    
    # continue the loop which should reprocess the same file
    #		with the correct comparision against a file and not a dir
    continue;
    else
    # Neither files exists, Copy new File
    echo "Mockturtle file doesnt exist"
    
    origDirName=$(dirname "$file")
    newDirName="${origDirName//$TdarrDir/$PlexDir}"
    mkdir -p "$newDirName"
    
    echo "Coping New File"
    cp "$file" "$WrMkvFile"
    if [ $? -eq 0 ]
    then
        # copy complete, remove the original TS
        echo "removing recording '$file'"
        rm "$file"
    fi
    fi

############################################### End Copy/Move #################################

    echo "Next"
    file=''
    read -d $'\0' file < <(find $TdarrDir -path */.grab -prune -false -o -iname "*.mkv" -print0)
done
echo "Loop Complete"
echo "Clearing empty folders"
find $TdarrDir -type d -empty -delete
