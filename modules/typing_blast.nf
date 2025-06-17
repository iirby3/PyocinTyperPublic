process typing_blast {

    conda 'bioconda::blast conda-forge::pandas conda-forge::numpy'

    cpus "${params.blast_threads}"

    memory '20 GB'

    publishDir "${params.outdir}/blast_results/typing_blast_results", mode: 'copy'

    input:
        tuple val(ID), path(ref), path(R1), path(R2), path(R5), val(scripts), val(PID), val(NID)

    output:
        path "*${ID}.txt", emit: type_blast_output
        path "${ID}_*_list.txt", emit: type_list
        path "${ID}_pyocin_summary_table.csv", emit: typing_summary_table

    script:
    """
    makeblastdb -in $ref -parse_seqids -out ${ref}_blast_db/${ref}_blast_db -dbtype nucl

    blastn -query $R1 -task blastn -db "${ref}_blast_db/${ref}_blast_db" -outfmt "6 qseqid sseqid sacc pident nident qlen length evalue slen qstart qend sstart send" -evalue 0.01 -num_threads $params.blast_threads >> R1_${ID}.txt
    blastn -query $R2 -task blastn -db "${ref}_blast_db/${ref}_blast_db" -outfmt "6 qseqid sseqid sacc pident nident qlen length evalue slen qstart qend sstart send" -evalue 0.01 -num_threads $params.blast_threads >> R2_${ID}.txt
    blastn -query $R5 -task blastn -db "${ref}_blast_db/${ref}_blast_db" -outfmt "6 qseqid sseqid sacc pident nident qlen length evalue slen qstart qend sstart send" -evalue 0.01 -num_threads $params.blast_threads >> R5_${ID}.txt

    python "${scripts}/R_typing.py" "R1_${ID}.txt" "R2_${ID}.txt" "R5_${ID}.txt" "$ID" "$PID" "$NID"
    """
}

