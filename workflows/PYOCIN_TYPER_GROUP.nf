#!/usr/bin/env nextflow

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS / WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { phispy } from '../modules/phispy.nf'
include { concatenate_paths } from '../modules/concatenate_paths.nf'
include { cd_hit } from '../modules/cd_hit.nf'
include { split_files } from '../modules/split_files.nf'
include { blast_db as all_blast_db } from '../modules/blast_db.nf'
include { blast_db as R_and_F_blast_db } from '../modules/blast_db.nf'
include { blast as R_and_F_blast } from '../modules/blast.nf'
include { blast as merged_blast } from '../modules/blast.nf'
include { reformat_pyocin_blast } from '../modules/reformat_pyocin_blast.nf'
include { sep_multifasta } from '../modules/sep_multifasta.nf'
include { sort_blast_new } from '../modules/sort_blast_new.nf'
include { combine_blast }from '../modules/combine_blast.nf'
include { move_confirmed_pyocins } from '../modules/move_confirmed_pyocins.nf'
include { typing_blast } from '../modules/typing_blast.nf'
include { move_typed_pyocins } from '../modules/move_typed_pyocins.nf'
include { merge_pyocins } from '../modules/merge_pyocins.nf'
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow PYOCIN_TYPER_GROUP {
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

        // Run cd-hit to cluster phage into families for comparison to R and F pyocins from PAO1
        cd_hit(
            concatenate_paths.out
        )

        // Split cd-hit result and reformat result
        split_files(
            cd_hit.out.cd_hit_cluster,
            scripts
        )

        // Make blast_db
        all_blast_db(
            cd_hit.out.cd_hit_fasta
        )

        // Run R and F pyocin blast
        R_and_F_blast(
            R_and_F_ch,
            all_blast_db.out.blast_db_path
        )

        R_and_F_blast_combined = R_and_F_blast.out.blast_output
            .combine(split_files.out.cluster_overview)
            .combine(split_files.out.ref_clusters)
            .combine(scripts)

        // Reformat the blast outputs
        reformat_pyocin_blast(
            R_and_F_blast_combined
        )

        // Seprate multifasta file
        sep_multifasta(
            concatenate_paths.out,
            reformat_pyocin_blast.out.pyocin_list
        )

        merge_pyocins(sep_multifasta.out.all_pyocin_fasta.collect())

        // Run blast of R and F on all hypothesized pyocin clusters
        R_and_F_blast_db(
            merge_pyocins.out.merged_pyocins
        )

        R_and_F_ch_new = R_and_F_ch
            .map { id, file, PID, NID -> 
                def new_id = "all_${id}"
                tuple(new_id, file, PID, NID)
            }

        merged_blast(
            R_and_F_ch_new,
            R_and_F_blast_db.out.blast_db_path
        )

        merge_blast_collect = merged_blast.out.blast_output
            .map { tuple -> tuple[1] }
            .collect()

        pyocin_list_collect = reformat_pyocin_blast.out.pyocin_list
            .map { tuple -> tuple[1] }
            .collect()

        // Combine blast and list outputs
        combine_blast(
            merge_blast_collect,
            pyocin_list_collect,
            )

        // Assign pyocin as R/F/RF/Unconfirmed
        sort_blast_new(
            combine_blast.out.combined_R_F_blast,
            combine_blast.out.combined_R_F_list,
            params.R_pyocin_PID_cutoff,
            params.R_pyocin_NID_cutoff,
            params.F_pyocin_PID_cutoff,
            params.F_pyocin_NID_cutoff,
            scripts
            )

        sort_blast_new_ch = sort_blast_new.out.final_lists
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