process split_files {

    conda 'conda-forge::pandas conda-forge::numpy'

    publishDir "${params.outdir}/cd-hit", mode: 'copy'

    input:
        path input_file
        val scripts

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

    python "${scripts}/reformat_cd_hit.py"

    """
}