process summary_table {

    publishDir "${params.outdir}/summary_files", mode: 'copy'

    input:
        path all_typed
        path R_RF_subtyped

    output:
        path "final_summary_types_subtypes.csv"

    script:
    """
    summary_table.py "$all_typed" "$R_RF_subtyped"
    """
}

