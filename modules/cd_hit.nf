process cd_hit {

    conda 'bioconda::blast=2.12'

    publishDir "${params.outdir}/cd-hit", mode: 'copy'

    memory '8 GB'

    input:
        path input_file

    output:
        path "*.clstr", emit: cd_hit_cluster
        path "prophage_clusters", emit: cd_hit_fasta

    script:
    """
    psi-cd-hit.pl -i ${input_file} -o "prophage_clusters" -c $params.cd_hit_cluster -prog blastn

    """
}

