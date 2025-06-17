process blast_db {

    conda 'bioconda::blast'

    input:
        path ref

    output:
        path "${ref}_blast_db*", emit: blast_db_path

    script:
    """
    makeblastdb -in $ref -parse_seqids -out ${ref}_blast_db/${ref}_blast_db -dbtype nucl

    """
}

