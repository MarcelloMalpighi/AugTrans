# AugTrans
An augmented transcript-level RNA-seq quantification pipeline (under development).
Novel transcripts from alternative splicing events have been recognized for their role in shaping various biological processes. However, prior studies focused on gene-level expression, overlooking transcript-level information. Moreover, transposable elements (TEs) previously considered non-expressed are now known to be widely expressed in tumor tissues, suggesting great potential as tumor-specific antigen targets by providing protein-coding and regulatory sequences to novel transcripts. The availability of high-quality full-length scRNA-seq datasets, along with EM-based tools such as Salmon that demonstrate high quantification accuracy, enables further investigation in these two aspects. Based on these insights, we developed an augmented transcript-level quantification pipeline for a reference transcriptome comprising 1,000,000 well-annotated transcripts and 3,000,000 TE loci.
```
Usage: AugTransConstruct.sh -g <geneGtfFile> -t <TEGtfFile> -r <refGenome> -o <outputLoc> -p <threads>
  -g gene gtf file
  -t TE gtf file
  -r reference genome fasta file
  -o output location, without / at the end
  -h help
  -p number of threads (default: 1)
```
```
Usage: AugTransQuantify.sh -i <inputFile> -g <transcriptsIndex> -t <tesIndex> -o <outputDir> -p <threads>
  -i input file, fastq
  -g transcripts index
  -t TEs index
  -o output directory, without / at the end
  -h help
  -p number of threads (default: 1)
```
  The augmented human transcript and TE reference GTF files could be accessed from [AugTransTEs.gtf.gz](https://univtokyo-my.sharepoint.com/:u:/g/personal/7869888610_utac_u-tokyo_ac_jp/EXacdKNoTUlLpUEhmdClmgkBKBr7cG5n1VMU8CwhS_WL_w?e=IFPJJs) and [AugTransTranscripts.gtf.gz](https://univtokyo-my.sharepoint.com/:u:/g/personal/7869888610_utac_u-tokyo_ac_jp/EWLpvsXsi55FhDEbx7_74Q8B24StOIjgnFR7gZqQeppbAg?e=lj18Td). Correspinding GENCODE v47 human reference genome fasta file could be downloaded from [here](https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_47/GRCh38.primary_assembly.genome.fa.gz).
