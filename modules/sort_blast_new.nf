process sort_blast_new {

    conda 'conda-forge::pandas conda-forge::numpy'

    publishDir "${params.outdir}/pyocin_overall_type_results", mode: 'copy'

    input:
        path combined_blast
        path combined_list
        val R_pyocin_PID
        val R_pyocin_NID
        val F_pyocin_PID
        val F_pyocin_NID
        val scripts

    output:
    path "Pyocin_typed.csv", emit: all_typed
    path "*.txt", emit: final_lists

    script:
    """
    python "${scripts}/sort_blast_new.py" "$combined_list" "$combined_blast" "$R_pyocin_PID" "$R_pyocin_NID" "$F_pyocin_PID" "$F_pyocin_NID"

    """
}