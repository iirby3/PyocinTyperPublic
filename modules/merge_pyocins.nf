process merge_pyocins {

    publishDir "${params.outdir}/pyocin_fasta", mode: 'copy'

    input:
        path all_pyocins

    output:
        path "merged_deduplicated_pyocins.fasta", emit: merged_pyocins

    script:
    """
    cat $all_pyocins > merged_all_pyocins.tmp.fasta
    seqkit rmdup -n merged_all_pyocins.tmp.fasta > merged_deduplicated_pyocins.fasta
    """
}