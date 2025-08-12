#!/usr/bin/env nextflow

include { phispy } from '../modules/phispy.nf'
include { vclust } from '../modules/vclust.nf'
include { concat_vclust_reps } from '../modules/concat_vclust_reps.nf'
include { split_files } from '../modules/split_files.nf'
include { blast_db as all_blast_db } from '../modules/blast_db.nf'
include { blast_db as R_and_F_blast_db } from '../modules/blast_db.nf'
include { blast as R_and_F_blast } from '../modules/blast.nf'
include { blast as merged_blast } from '../modules/blast.nf'
include { reformat_pyocin_blast } from '../modules/reformat_pyocin_blast.nf'
include { sep_multifasta } from '../modules/sep_multifasta.nf'
include { sort_blast_new } from '../modules/sort_blast_new.nf'
include { move_confirmed_pyocins } from '../modules/move_confirmed_pyocins.nf'
include { typing_blast } from '../modules/typing_blast.nf'
include { move_typed_pyocins } from '../modules/move_typed_pyocins.nf'
include { merge_pyocins } from '../modules/merge_pyocins.nf'
include { summary_table } from '../modules/summary_table.nf'

//
// WORKFLOW: PYOCIN_TYPER_GROUP
//

workflow PYOCIN_TYPER_GROUP {
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
        
        // Use vclust to cluster all potential phage regions on an ani threshold
        vclust(
            concatenate_paths_ch
        )
        
        vclust_multifasta_ch = vclust.out.vclust_list
            .combine( concatenate_paths_ch )

        concat_vclust_reps(
            vclust_multifasta_ch
        )

        // Make blast_db
        all_blast_db(
            concat_vclust_reps.out
        )

        R_and_F_blast_ch = R_and_F_ch
            .combine(all_blast_db.out.blast_db_path)

        // Run R and F pyocin blast
        R_and_F_blast(
            R_and_F_blast_ch
        )

        R_and_F_blast_combined = R_and_F_blast.out.blast_output
            .combine(vclust.out.vclust_summary_table)
            .combine(vclust.out.vclust_rep_table)

        // Reformat the blast outputs
        reformat_pyocin_blast(
            R_and_F_blast_combined
        )

        pyocin_list_multi_ch = reformat_pyocin_blast.out.pyocin_list
            .combine( concatenate_paths_ch )
        
        // Separate multifasta file
        sep_multifasta(
            pyocin_list_multi_ch
        )

        merge_pyocins(
            sep_multifasta.out.all_pyocin_fasta
            .collect()
        )

        // Run blast of R and F on all hypothesized pyocin clusters
        R_and_F_blast_db(
            merge_pyocins.out.merged_pyocins
        )

        R_and_F_ch_new = R_and_F_ch
            .map { id, file, PID, NID -> 
                def new_id = "all_${id}"
                tuple(new_id, file, PID, NID)
            }
            .combine( R_and_F_blast_db.out.blast_db_path )

        merged_blast(
            R_and_F_ch_new
        )

        merge_blast_collect_ch =  merged_blast.out.blast_output
            .map { tuple -> tuple[1] }
            .collectFile(
                storeDir: "${params.outdir}/blast_results",
                name: 'combined_R_F_blast.txt'
            )

        pyocin_list_collect_ch =  reformat_pyocin_blast.out.pyocin_list
            .map { tuple -> tuple[1] }
            .collectFile(
                storeDir: "${params.outdir}/blast_results",
                name: 'combined_R_F_list.txt'
            )

        // Assign pyocin as R/F/RF/Unconfirmed
        sort_blast_new(
            merge_blast_collect_ch,
            pyocin_list_collect_ch
            )

        sort_blast_new_ch = sort_blast_new.out.final_lists
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

        // Collect R and RF subtypes
        R_RF_subtyped_ch =  typing_blast.out.typing_summary_table
            .collectFile(
                storeDir: "${params.outdir}/summary_files",
                name: 'R_RF_subtypes.csv',
                keepHeader: true
            )

        summary_table(
            sort_blast_new.out.all_typed,
            R_RF_subtyped_ch
        )

}