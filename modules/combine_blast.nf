process combine_blast {

    publishDir "${params.outdir}/blast_results", mode: 'copy'

    input:
        path(merged_blast)
        path(pyocin_list)

    output:
        path "combined_R_F_blast.txt", emit: combined_R_F_blast
        path "combined_R_F_list.txt", emit: combined_R_F_list

        
    script:
    """
    cat $merged_blast > combined_R_F_blast.txt
    cat $pyocin_list > combined_R_F_list.txt

    """
}