process move_confirmed_pyocins {

    publishDir "${params.outdir}/pyocin_fasta/confirmed_fasta", mode: 'copy'

    input:
        tuple val(ID), path(list), path(multifasta)

    output:
        path "confirmed_${ID}_pyocin_fasta/*", optional: true, emit: confirmed_pyocin_fasta
        tuple val(ID), path("all_confirmed_${ID}.fasta"), optional: true, emit: all_confirmed_fasta

        
    script:
    """
    # Separate multifasta file
    awk '/^>/ {out = substr(\$1, 2) ".fasta"; print > out} !/^>/ {print >> out}' $multifasta

    if [ -s "$list" ]; then
        mkdir -p confirmed_${ID}_pyocin_fasta

        while read FILE;
        do
            cp \$FILE.fasta confirmed_${ID}_pyocin_fasta/\${FILE}.fasta
        done < $list
    fi

    if [[ "$ID" == "R" ]]; then
        if [ -s  $list ]; then
            cat confirmed_${ID}_pyocin_fasta/*.fasta >> all_confirmed_${ID}.fasta
        else
            echo "No confirmed R pyocins present."
        fi
    fi

    if [[ "$ID" == "RF" ]]; then
        if [ -s  $list ]; then
            cat confirmed_${ID}_pyocin_fasta/*.fasta >> all_confirmed_${ID}.fasta
        else
            echo "No confirmed RF pyocins present."
        fi
    fi
    """
}