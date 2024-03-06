process RECOMBINATION_GUBBINS {

    tag ( "${meta.aligner}" )
    container "snads/gubbins@sha256:391a980312096f96d976f4be668d4dea7dda13115db004a50e49762accc0ec62"

    input:
    tuple val(meta), path(snp_files)

    output:
    tuple val(meta), path("*.{gff,tree}"), emit: positions_and_tree
    path(".command.{out,err}")
    path("versions.yml")                 , emit: versions

    shell:
    '''
    source bash_functions.sh

    msg "INFO: Performing recombination using Gubbins."
    run_gubbins.py --starting-tree "!{meta.aligner}.tree" --prefix Gubbins "!{meta.aligner}.SNPs.fa"

    # Rename output files
    mv Gubbins.recombination_predictions.gff Gubbins.recombination_positions.gff
    mv Gubbins.node_labelled.final_tree.tre Gubbins.labelled_tree.tree

    cat <<-END_VERSIONS > versions.yml
    "!{task.process}":
        gubbins: $(run_gubbins.py --version | sed 's/^/    /')
    END_VERSIONS
    '''
}
