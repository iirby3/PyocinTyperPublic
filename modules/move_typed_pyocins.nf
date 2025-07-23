process move_typed_pyocins {

    publishDir "${params.outdir}/pyocin_fasta/typed", mode: 'copy'

    input:
        tuple val(ID), val(type), path(list), path(multifasta)

    output:
        path "${ID}/${type}_pyocin_fasta/*", optional: true

        
    script:
    """
    # Separate multifasta file
    awk '/^>/ {out = substr(\$1, 2) ".fasta"; print > out} !/^>/ {print >> out}' $multifasta

    if [ -s "$list" ]; then
        mkdir -p ${ID}/${type}_pyocin_fasta

        while read FILE;
        do
            cp \$FILE.fasta ${ID}/${type}_pyocin_fasta/\${FILE}.fasta
        done < $list
    fi

    """
}