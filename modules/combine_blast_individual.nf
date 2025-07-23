process combine_blast_individual {

    publishDir "${params.outdir}/blast_results", mode: 'copy'

    input:
        path merged_blast
        
    output:
        path "combined_R_F_blast.txt", emit: combined_R_F_blast
        
    script:
    """
    cat $merged_blast > combined_R_F_blast.txt

    """
}