#!/bin/bash
### 2025.04.19
### Run quantification for AugTrans

### 1. getopts
while getopts "i:t:" opt
do
    case $opt in
        i)
            inputFile=$OPTARG
            ;;
        p)
            threads=$OPTARG
            ;;
        g)
            transcriptsIndex=$OPTARG
            ;;
        t)
            tesIndex=$OPTARG
            ;;
        o)
            outputDir=$OPTARG
            ;;
        h)
            echo "Usage: AugTransQuantify.sh -i <inputFile> -g <transcriptsIndex> -t <tesIndex> -o <outputDir> -p <threads>"
            echo "  -i input file, fastq or bam"
            echo "  -g transcripts index"
            echo "  -t TEs index"
            echo "  -o output directory, without / at the end"
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

if [ -z ${inputFile} ] || [ -z ${transcriptsIndex} ] || [ -z ${tesIndex} ] || [ -z ${outputDir} ]
    then
    echo "Please provide all required parameters"
    echo "Usage: AugTransQuantify.sh -i <inputFile> -g <transcriptsIndex> -t <tesIndex> -o <outputDir> -p <threads>"
    echo "  -i input file, fastq or bam"
    echo "  -g transcripts index"
    echo "  -t TEs index"
    echo "  -o output directory, without / at the end"
    echo "  -h help"
    echo "  -p number of threads (default: 1)"
    exit 1
fi

if [ -z ${threads} ]
    then
    threads=1
fi

### 2.1 quant
### insertSize should not be used because it needs bam file, which is not generated in salmon pipeline
mkdir -p ${outputDir}/Transcripts
mkdir -p ${outputDir}/TEs

for j in Transcripts TEs
do
cd ${outputDir}/${j}
if [[ $j == "transcripts" ]]
then
ref=${transcriptsIndex}
else
ref=${tesIndex}
fi
/usr/bin/time -v -o ${outputDir}/${j}/${j}.time salmon quant \
-l U \
--allowDovetail \
--dumpEq \
--writeUnmappedNames \
--writeOrphanLinks \
--writeQualities \
--writeMappings=${outputDir}/${j}/${j}.sam \
-p ${threads} \
-i ${ref} \
-r ${inputFile} \
-o ${outputDir}/${j} &> ${outputDir}/${j}/${j}.log

### 2.2 sam to bam
samtools view -@ ${threads} -bS ${outputDir}/${j}/${j}.sam > ${outputDir}/${j}/${j}.bam
rm -rf ${outputDir}/${j}/${j}.sam
done