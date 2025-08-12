process phispy {
    
    cpus "${params.phispy_threads}"

    conda 'bioconda::phispy'

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

    if sed --version >/dev/null 2>&1; then
        # GNU sed (Linux)
        SED_INPLACE=(-i)
    else
        # BSD sed (macOS)
        SED_INPLACE=(-i '')
    fi

    sed "\${SED_INPLACE[@]}" "s/^>\\(.*\\)/>\\1_\${base}/" \${base}_phage.fasta
    sed "\${SED_INPLACE[@]}" "s/\\[//g" \${base}_phage.fasta
    sed "\${SED_INPLACE[@]}" "s/\\]//g" \${base}_phage.fasta
    sed "\${SED_INPLACE[@]}" 's/ /_/g' \${base}_phage.fasta

    """
}

