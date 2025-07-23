process sort_blast_new_individual {
    
    publishDir "${params.outdir}/pyocin_overall_type_results", mode: 'copy'

    input:
        path combined_blast

    output:
    path "Pyocin_typed.csv", emit: all_typed
    path "*.txt", emit: final_lists

    script:
    """
    sort_blast_new_individual.py "$combined_blast" "$params.R_pyocin_PID_cutoff" "$params.R_pyocin_NID_cutoff" "$params.F_pyocin_PID_cutoff" "$params.F_pyocin_NID_cutoff"
    """
}