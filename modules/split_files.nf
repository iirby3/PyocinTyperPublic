process split_files {
    
    publishDir "${params.outdir}/cd-hit", mode: 'copy'

    input:
        path input_file

    output:
        path "Clusters_overview_table.csv", emit: cluster_overview
        path "ref_list_cluster.txt", emit: ref_clusters
        
    script:
    """
    awk '/^>Cluster/ {x="file"++i; next} {print > x}' $input_file
    
    reformat_cd_hit.py

    """
}