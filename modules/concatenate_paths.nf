process concatenate_paths {

    publishDir "${params.outdir}/concatenated_phage_fasta", mode: 'copy'

    input:
        tuple val(ID), path(input_files)

    output:
        path "*"

    script:
    """
    cat ${input_files.join(' ')} > "$ID"
    """
}