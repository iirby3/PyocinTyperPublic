process vclust {
    
    publishDir "${params.outdir}/vclust", mode: 'copy'

    memory '8 GB'

    input:
        path input_file

    output:
        path "vclust_summary_table.csv", emit:vclust_summary_table
        path "vclust_representitives_per_cluster.csv", emit:vclust_rep_table
        path "vclust_representitives_per_cluster_list.txt", emit: vclust_list


    script:
    """
    vclust prefilter -i ${input_file} -o vclust_fltr.txt

    vclust align -i ${input_file} -o vclust_ani.tsv --filter vclust_fltr.txt --filter-threshold $params.vclust_ani

    vclust cluster -i vclust_ani.tsv -o vclust_clusters.tsv --ids vclust_ani.ids.tsv --algorithm $params.vclust_algorithm \
    --metric ani --ani $params.vclust_ani --qcov $params.vclust_qcov --rcov $params.vclust_rcov --len_ratio $params.vlcust_len_ratio

    reformat_vclust.py "vclust_clusters.tsv"
    """
}

