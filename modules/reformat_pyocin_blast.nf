process reformat_pyocin_blast {

    publishDir "${params.outdir}/blast_results", mode: 'copy'

    input:
        tuple val(ID), path(blast_result), val(PID), val(NID), path(cluster_overview), path(ref_clusters)

    output:
        tuple val(ID), path("${ID}_fasta.txt"), emit: pyocin_fasta
        tuple val(ID), path("${ID}_list.txt"), emit: pyocin_list
        
    script:
    """
    pyocin_analysis_new.py "$blast_result" "$ID" "$PID" "$NID"
    reformat_pyocins_new.py "$cluster_overview" "$ref_clusters" "${ID}_fasta.txt" "$ID"

    """
}