process sep_multifasta {

    publishDir "${params.outdir}/pyocin_fasta", mode: 'copy'

    input:
        path multifasta
        tuple val(ID), path(list)


    output:
        tuple val(ID), path("${ID}_pyocin_fasta/*"), emit: ind_pyocin_fasta
        path "all_${ID}_pyocin.fasta", emit: all_pyocin_fasta
        
    script:
    """
    # Separate multifasta file
    awk '/^>/ {out = substr(\$1, 2) ".fasta"; print > out} !/^>/ {print >> out}' $multifasta
    
    # Make directory for pyocin fasta
    mkdir -p ${ID}_pyocin_fasta

    # Move files
    while read FILE;
    do
        cp \$FILE.fasta ${ID}_pyocin_fasta/\${FILE}.fasta
    done < ${list}

    # Concatenate files
    cat ${ID}_pyocin_fasta/*.fasta >> all_${ID}_pyocin.fasta
    """
}