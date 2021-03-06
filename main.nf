#!/usr/bin/env nextflow

params.in = file("$baseDir/combined.fa")
params.pangolin_options = ''
params.outdir = 'out'

process pangolin {
    publishDir "${params.outdir}", mode: 'copy'
    tag 'pangolin'

    container 'staphb/pangolin:latest'

    input:
    file(fasta) from file(params.in)

    output:
    file('lineage_report.csv') into pangolin_file
    file("logs/${task.process}/${task.process}.${workflow.sessionId}.{log,err}")

    shell:
    '''
      mkdir -p !{task.process} logs/!{task.process}
      log_file=logs/!{task.process}/!{task.process}.!{workflow.sessionId}.log
      err_file=logs/!{task.process}/!{task.process}.!{workflow.sessionId}.err

      date | tee -a $log_file $err_file > /dev/null
      pangolin --version >> $log_file
      pangolin --pangoLEARN-version >> $log_file

      cat !{fasta} > ultimate_consensus.fasta

      pangolin !{params.pangolin_options} \
        ultimate_consensus.fasta \
        2>> $err_file >> $log_file
    '''
}
