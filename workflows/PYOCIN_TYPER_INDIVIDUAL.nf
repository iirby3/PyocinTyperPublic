#!/usr/bin/env nextflow

include { phispy } from '../modules/phispy.nf'
include { blast_db as all_blast_db } from '../modules/blast_db.nf'
include { blast as R_and_F_blast } from '../modules/blast.nf'
include { sort_blast_new_individual } from '../modules/sort_blast_new_individual.nf'
include { move_confirmed_pyocins } from '../modules/move_confirmed_pyocins.nf'
include { typing_blast } from '../modules/typing_blast.nf'
include { move_typed_pyocins } from '../modules/move_typed_pyocins.nf'
include { merge_pyocins } from '../modules/merge_pyocins.nf'

//
// WORKFLOW: PYOCIN_TYPER_INDIVIDUAL
//

workflow PYOCIN_TYPER_INDIVIDUAL {
    take:
        input_files_ch
        R_and_F_ch
        R1_ch
        R2_ch
        R5_ch
    main:
        // Run phispy on all inputs
        phispy(
            input_files_ch
        )

        // Concatenate all phage fasta from phispy
        concatenate_paths_ch =  phispy.out.phage_fasta
            .collectFile(
                storeDir: "${params.outdir}",
                name: 'all_prophage.fasta'
            )
        
        // Make blast_db
        all_blast_db(
            concatenate_paths_ch
        )
        
        R_and_F_blast_ch = R_and_F_ch
            .combine(all_blast_db.out.blast_db_path)


        // Run R and F pyocin blast
        R_and_F_blast(
            R_and_F_blast_ch
        )

        merge_blast_collect_ch =  R_and_F_blast.out.blast_output
            .map { tuple -> tuple[1] }
            .collectFile(
                storeDir: "${params.outdir}/blast_results",
                name: 'combined_R_F_blast.txt'
            )

        sort_blast_new_individual(
            merge_blast_collect_ch
            )

        sort_blast_new_ch = sort_blast_new_individual.out.final_lists
            .flatten()
            .map { file ->
            def type = (file.name =~ /Confirmed_(\w+)_Pyocins\.txt/)[0][1]
            tuple(type, file)
            }
            .combine( concatenate_paths_ch )


        // Move confirmed pyocins
        move_confirmed_pyocins(
            sort_blast_new_ch
            )

        confirmed_pyocins_combined = move_confirmed_pyocins.out.all_confirmed_fasta
            .combine(R1_ch)
            .combine(R2_ch)
            .combine(R5_ch)

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
            .combine( concatenate_paths_ch )

        // Move typed pyocins
        move_typed_pyocins(
            typing_blast_ch
        )

}