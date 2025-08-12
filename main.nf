#!/usr/bin/env nextflow

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PyocinTyper
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/GaTechBrownLab/PyocinTyper
    Author: Iris Irby, irisirby2018@gmail.com
----------------------------------------------------------------------------------------
*/

//
// HELP MESSAGE
//
def helpMessage() {
    log.info"""
    =========================================
     PyocinTyper
    =========================================
    Usage:
    nextflow run main.nf -with-conda --pt_option <group|individual>
        --input_files = "./data/*.gbff" --outdir "/results"

    Required arguments:
        --pt_option                 Specifiy if you are typing multiple pyocins <group>
                                    or a single pyocin <individual>
        --input_files               Path to input genbank (.gbff) files
                                    Directory pattern for individual: "./data/strain.gbff"
                                    Directory pattern for group: "./data/*.gbff" 
        --outdir                    Output directory for results

    Blast thresholds:
        --R_pyocin_PID_cutoff       Percent identity cutoff for R pyocins
                                    (default: 70)
        --R_pyocin_NID_cutoff       Nucleotide identity cutoff for R pyocins
                                    (default: 70)
        --F_pyocin_PID_cutoff       Percent identity cutoff for F pyocins
                                    (default: 65)
        --F_pyocin_NID_cutoff       Nucleotide identity cutoff for F pyocins
                                    (default: 65)
        --tail_PID_cutoff           Percent identity cutoff for tail fibers
                                    (default: 95)
        --tail_NID_cutoff           Nucleotide identity cutoff for tail fibers
                                    (default: 95)

    vclust parameters:
        --vclust_ani                Clustering level for vclust ani
                                    (default: 0.70)
        --vclust_algorithm          Algorithm for vclust
                                    (default: cd-hit)
        --vclust_qcov               Query coverage for vclust
                                    (default: 0.70)
        --vlust_rcov                Reference coverage for vclust
                                    (default: 0.70)
        --vlcust_len_ratio          Length ratio for vclust
                                    (default: 0.70)

    Performance options:
        --phispy_threads            Specify number of threads for PhiSpy
                                    (default: 1)
        --blast_threads             Specify number of threads for blast
                                    (default: 1)
        
    """.stripIndent()
}

//
// IMPORT WORKFLOWS
//

include { PYOCIN_TYPER_GROUP } from './workflows/PYOCIN_TYPER_GROUP.nf'
include { PYOCIN_TYPER_INDIVIDUAL } from './workflows/PYOCIN_TYPER_INDIVIDUAL.nf'

//
// RUN MAIN WORKFLOW
//

workflow {
    main:
        // Show help message
        if (params.help){
            helpMessage()
            exit 0
        }

        // Validate parameters
        if (!params.input_files) {
            exit 1, "No input file provided! Please set `--input_files` to a valid path."
        }

        if (!params.outdir) {
            exit 1, "No output directory provided! Please set `--outdir` to a valid path."
        }

        // Make channels from parameters
        input_files_ch = Channel.fromPath( params.input_files )

        // Validate channels
        input_files_ch
            .collect()
            .map { files ->

            def file_count = files.size()

            if (!params.pt_option || !(params.pt_option in ['group', 'individual'])) {
                exit 1, "No pt_option or incorrect pt_option specified! Please specify '--pt_option' to 'group' or 'individual'."
            }

            if (params.pt_option== 'group' && file_count <= 1) {
                exit 1, "'--pt_option group' requires more than one input file."
            }

            if (params.pt_option == 'individual' && file_count != 1) {
                exit 1, "'--pt_option individual' requires a single input file."
            }

            // Optionally re-emit as channel if you still want to use it downstream
            input_files_ch = Channel.from(files)
        }

        // Read in reference files
        R_pyocin_ch = Channel.fromPath( "./references/PAO1_R_Pyocin.fasta" )
            .map {  file -> tuple( "PAO1_R_Pyocin", file, params.R_pyocin_PID_cutoff, params.R_pyocin_NID_cutoff ) }
        F_pyocin_ch = Channel.fromPath( "./references/PAO1_F_Pyocin.fasta" )
            .map { file -> tuple( "PAO1_F_Pyocin", file, params.F_pyocin_PID_cutoff, params.F_pyocin_NID_cutoff ) }
        R_and_F_ch = R_pyocin_ch
            .mix( F_pyocin_ch )

        R1_ch = Channel.fromPath( "./references/R1_800bp.fasta" )
        R2_ch = Channel.fromPath( "./references/R2_800bp.fasta" )
        R5_ch = Channel.fromPath( "./references/R5_800bp.fasta" )

        // Run workflow
        if (params.pt_option == "group") {
            PYOCIN_TYPER_GROUP(
                input_files_ch,
                R_and_F_ch,
                R1_ch,
                R2_ch,
                R5_ch
            )
        } else if (params.pt_option == "individual") {
            PYOCIN_TYPER_INDIVIDUAL(
                input_files_ch,
                R_and_F_ch,
                R1_ch,
                R2_ch,
                R5_ch
            )
        } 
}