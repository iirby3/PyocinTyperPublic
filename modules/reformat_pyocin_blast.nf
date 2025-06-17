process reformat_pyocin_blast {

    conda 'conda-forge::pandas conda-forge::numpy'

    publishDir "${params.outdir}/blast_results", mode: 'copy'

    input:
        tuple val(ID), path(blast_result), val(PID), val(NID), path(cluster_overview), path(ref_clusters), val(scripts)

    output:
        tuple val(ID), path("${ID}_fasta.txt"), emit: pyocin_fasta
        tuple val(ID), path("${ID}_list.txt"), emit: pyocin_list
        
    script:
    """
    python "${scripts}/pyocin_analysis_new.py" "$blast_result" "$ID" "$PID" "$NID"
    python "${scripts}/reformat_pyocins_new.py" "$cluster_overview" "$ref_clusters" "${ID}_fasta.txt" "$ID"

    """
}