#!/bin/bash
### 2025.04.19
### Construct the reference transcriptome and corresponding index for AugTrans

### 1. getopts
while getopts "g:t:r:o:p:h" opt
do
    case $opt in
        g)
            geneGtfFile=$OPTARG
            ;;
        t)
            TEGtfFile=$OPTARG
            ;;
        r)
            refGenome=$OPTARG
            ;;
        o)
            outputLoc=$OPTARG
            ;;
        p)
            threads=$OPTARG
            ;;
        h)
            echo "Usage: AugTransConstruct.sh -g <geneGtfFile> -t <TEGtfFile> -r <refGenome> -o <outputLoc> -p <threads>"
            echo "  -g gene gtf file"
            echo "  -t TE gtf file"
            echo "  -r reference genome fasta file"
            echo "  -o output location, without / at the end"
            echo "  -h help"
            echo "  -p number of threads (default: 1)"
            exit 0
            ;;
        ?)
            echo "Unknown parameter"
            exit 1
            ;;
    esac
done

if [ -z ${geneGtfFile} ] || [ -z ${TEGtfFile} ] || [ -z ${refGenome} ] || [ -z ${outputLoc} ]
    then
    echo "Please provide all required parameters"
    echo "Usage: AugTransConstruct.sh -g <geneGtfFile> -t <TEGtfFile> -r <refGenome> -o <outputLoc> -p <threads>"
    echo "  -g gene gtf file"
    echo "  -t TE gtf file"
    echo "  -r reference genome fasta file"
    echo "  -o output location, without / at the end"
    echo "  -h help"
    echo "  -p number of threads (default: 1)"
    exit 1
fi

if [ -z ${threads} ]
    then
    threads=1
fi

### 2. generate transcriptome fasta files and index
for j in ${geneGtfFile} ${TEGtfFile}
    do
    cd ${outputLoc}
    if [ $j == ${geneGtfFile} ]
        then
        name="AugTransTranscripts"
    elif [ $j == ${TEGtfFile} ]
        then
        name="AugTransTEs"
    fi
    # generate the transcriptome fasta files
    awk '($1!~/^#/){print $1}' ${j} | sort| uniq | grep chr > ${name}.chr.list
    awk '($1!~/^#/){print $1}' ${j} | sort| uniq > ${name}.ID.list
    mkdir ${outputLoc}/gffread_${name}
    grep -E -v "^#" ${outputLoc}/${j} | awk '($1!~/^chr/){print $0}' > ${outputLoc}/gffread_${name}/${name}.left.gtf
    for i in `cat ${outputLoc}/${name}.chr.list`
        do
        cd ${outputLoc}/gffread_${name}
        awk -v chr=${i} '{if($1==chr)print $0}' ${outputLoc}/${j} > ${outputLoc}/gffread_${name}/${name}.$i.gtf
        gffread -w ${outputLoc}/gffread_${name}/${name}.$i.fa -g ${refGenome} ${outputLoc}/gffread_${name}/${name}.$i.gtf & # manual multiple threads for gffread
        done
    gffread -w ${outputLoc}/gffread_${name}/${name}.left.fa -g ${refGenome} ${outputLoc}/gffread_${name}/${name}.left.gtf
    echo -e "${j} generating done"
    ## combine all fasta files
    for i in `cat ${outputLoc}/${name}.chr.list`
        do
        cat ${outputLoc}/gffread_${name}/${name}.$i.fa >> ${outputLoc}/${name}.fa
        done
    cat ${outputLoc}/gffread_${name}/${name}.left.fa >> ${outputLoc}/${name}.fa
    echo ${j} combining done
    # index
    pigz -k -p ${threads} ${outputLoc}/${name}.fa
    mkdir ${outputLoc}/${name}Index
    grep "^>" <(gunzip -c ${refGenome}) | cut -d " " -f 1 > ${outputLoc}/${name}Index/decoys.txt
    sed -i.bak -e 's/>//g' ${outputLoc}/${name}Index/decoys.txt
    cat ${outputLoc}/${name}.fa.gz ${refGenome}.gz > ${outputLoc}/${name}Index/gentrome.fa.gz
    salmon index -t ${outputLoc}/${name}Index/gentrome.fa.gz -d ${outputLoc}/${name}Index/decoys.txt -p ${threads} -i ${outputLoc}/${name}Index -k 15 --gencode
    done