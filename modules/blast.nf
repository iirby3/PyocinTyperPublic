process blast {

    conda 'bioconda::blast'

    cpus "${params.blast_threads}"

    memory '20 GB'

    publishDir "${params.outdir}/blast_results", mode: 'copy'

    input:
        tuple val(ID), path(query), val(PID), val(NID)
        path blast_db_path

    output:
        tuple val(ID), path("${ID}.txt"), val(PID), val(NID), emit: blast_output

    script:
    """  
    blastn -query $query -task blastn -db "${blast_db_path}/${blast_db_path}" -outfmt "6 qseqid sseqid sacc pident nident qlen length evalue slen qstart qend sstart send" -evalue 0.01 -num_threads $params.blast_threads >> ${ID}.txt
    """
}

