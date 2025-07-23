process split_files {
    
    publishDir "${params.outdir}/cd-hit", mode: 'copy'

    input:
        path input_file

    output:
        path "Clusters_overview_table.csv", emit: cluster_overview
        path "ref_list_cluster.txt", emit: ref_clusters
        
    script:
    """
    csplit -z ${input_file} /Cluster/ '{*}'

    for infile in xx*;
    do
        sed -i '1d' \${infile}
    done

    reformat_cd_hit.py

    """
}