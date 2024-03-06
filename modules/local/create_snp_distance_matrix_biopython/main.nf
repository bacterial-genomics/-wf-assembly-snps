process CREATE_SNP_DISTANCE_MATRIX_BIOPYTHON {

    tag ( "${meta.aligner}" )
    container "gregorysprenger/biopython@sha256:77a50d5d901709923936af92a0b141d22867e3556ef4a99c7009a5e7e0101cc1"

    input:
    tuple val(meta), path(snp_distances)

    output:
    tuple val(meta), path ("${meta.aligner}.SNP-Distances.Matrix.tsv")   , emit: distance_matrix
    tuple val(meta), path("${meta.aligner}.SNP_Distance_Matrix_File.tsv"), emit: qc_filecheck
    path("${snp_distances}.gz")
    path (".command.{out,err}")
    path ("versions.yml")                                                , emit: versions

    shell:
    '''
    source bash_functions.sh

    msg "INFO: Using SNP distances to create a distance matrix."

    pairwiseTo2d.py \
      -i "!{snp_distances}" \
      -o "!{meta.aligner}.SNP-Distances.Matrix.tsv" \
      --sort

    echo -e "Sample name\tQC step\tOutcome (Pass/Fail)" > "!{meta.aligner}.SNP_Distance_Matrix_File.tsv"
    if verify_minimum_file_size "!{meta.aligner}.SNP-Distances.Matrix.tsv" '!{meta.aligner} SNP Distance Matrix' "!{params.min_distance_matrix_filesize}"; then
      echo -e "NaN\t!{meta.aligner} SNP Distance Matrix\tPASS" >> "!{meta.aligner}.SNP_Distance_Matrix_File.tsv"
    else
      echo -e "NaN\t!{meta.aligner} SNP Distance Matrix\tFAIL" >> "!{meta.aligner}.SNP_Distance_Matrix_File.tsv"
    fi

    sed -i "s/\t-/\t0/g" "!{meta.aligner}.SNP_Distance_Matrix_File.tsv"

    # Gzip compress SNP distances
    gzip -9f !{snp_distances}

    cat <<-END_VERSIONS > versions.yml
    "!{task.process}":
        python: $(python --version)
    END_VERSIONS
    '''
}
