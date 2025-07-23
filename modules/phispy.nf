process phispy {
    
    cpus "${params.phispy_threads}"

    publishDir "${params.outdir}/phispy", mode: 'copy'

    input:
        path input_file

    output:
        path "*_phage.fasta", emit: phage_fasta
        path "*_phispy_results", emit: phispy_results

    script:
    """
    base=\$(basename "$input_file" ".gbff")

    PhiSpy.py $input_file --output_choice 5 -o \${base}_phispy_results --threads $params.phispy_threads

    cp \${base}_phispy_results/phage.fasta \${base}_phage.fasta

    sed -i "s/^>\\(.*\\)/>\\1_\${base}/" \${base}_phage.fasta
    sed -i "s/\\[//g" \${base}_phage.fasta
    sed -i "s/\\]//g" \${base}_phage.fasta
    sed -i 's/ /_/g' \${base}_phage.fasta

    """
}

