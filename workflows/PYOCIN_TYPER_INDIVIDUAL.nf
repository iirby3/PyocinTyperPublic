#!/usr/bin/env nextflow

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS / WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { phispy } from '../modules/phispy.nf'
include { concatenate_paths } from '../modules/concatenate_paths.nf'
include { blast_db as all_blast_db } from '../modules/blast_db.nf'
include { blast as R_and_F_blast } from '../modules/blast.nf'
include { sort_blast_new_individual } from '../modules/sort_blast_new_individual.nf'
include { combine_blast_individual }from '../modules/combine_blast_individual.nf'
include { move_confirmed_pyocins } from '../modules/move_confirmed_pyocins.nf'
include { typing_blast } from '../modules/typing_blast.nf'
include { move_typed_pyocins } from '../modules/move_typed_pyocins.nf'
include { merge_pyocins } from '../modules/merge_pyocins.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow PYOCIN_TYPER_INDIVIDUAL {
    take:
        input_files_ch
        R_and_F_ch
        R1_ch
        R2_ch
        R5_ch
        scripts
        tail_PID_cutoff_ch
        tail_NID_cutoff_ch
        
    main:
        // Run phispy on all inputs
        phispy(
            input_files_ch
        )

        // Reformat phispy output
        phage_ch_collect = phispy.out.phage_fasta
            .collect()
            .map {  file -> tuple( "all_prophage", file ) }

        // Concatenate all phage fasta from phispy
        concatenate_paths(
            phage_ch_collect
        )

        // Make blast_db
        all_blast_db(
            concatenate_paths.out
        )

        // Run R and F pyocin blast
        R_and_F_blast(
            R_and_F_ch,
            all_blast_db.out.blast_db_path
        )

        merge_blast_collect = R_and_F_blast.out.blast_output
            .map { tuple -> tuple[1] }
            .collect()

        combine_blast_individual(
            merge_blast_collect
        )

        sort_blast_new_individual(
            combine_blast_individual.out.combined_R_F_blast,
            params.R_pyocin_PID_cutoff,
            params.R_pyocin_NID_cutoff,
            params.F_pyocin_PID_cutoff,
            params.F_pyocin_NID_cutoff,
            scripts
            )

        sort_blast_new_ch = sort_blast_new_individual.out.final_lists
            .flatten()
            .map { file ->
            def type = (file.name =~ /Confirmed_(\w+)_Pyocins\.txt/)[0][1]
            tuple(type, file)
            }


        // Move confirmed pyocins
        move_confirmed_pyocins(
            concatenate_paths.out,
            sort_blast_new_ch
            )

        confirmed_pyocins_combined = move_confirmed_pyocins.out.all_confirmed_fasta
            .combine(R1_ch)
            .combine(R2_ch)
            .combine(R5_ch)
            .combine(scripts)
            .combine(tail_PID_cutoff_ch)
            .combine(tail_NID_cutoff_ch)

        // Type confirmed R pyocins as R1/R2/R5
        typing_blast(
            confirmed_pyocins_combined
            )
        
        typing_blast_ch = typing_blast.out.type_list
            .collect()
            .flatten()
            .map { file ->
                def match = (file.name =~ /^(.+?)_(R\d+)_list\.txt$/)
                def prefix = match ? match[0][1] : 'UnknownPrefix'
                def type = match ? match[0][2] : 'UnknownType'
                tuple(prefix, type, file)
            }

        // Move typed pyocins
        move_typed_pyocins(
            concatenate_paths.out,
            typing_blast_ch
        )

}