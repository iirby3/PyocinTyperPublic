process concat_vclust_reps {

    publishDir "${params.outdir}/pyocin_fasta/vclust_representitive_fasta", mode: 'copy'

    input:
        tuple path(list), path(multifasta)

    output:
        path "vclust_representitives.fasta"

        
    script:
    """
    # Separate multifasta file
    awk '/^>/ {out = substr(\$1, 2) ".fasta"; print > out} !/^>/ {print >> out}' $multifasta

    if [ -s "$list" ]; then
        mkdir -p vclust_refs

        while read FILE;
        do
            cp \$FILE.fasta vclust_refs/\${FILE}.fasta
        done < $list

        cat vclust_refs/*.fasta >> vclust_representitives.fasta

    else
        echo "Warning: no vclust results."
    fi
    """
}