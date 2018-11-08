#!/usr/bin/env nextflow

/*
 * SET UP CONFIGURATION VARIABLES
 */
bam = Channel
    .fromPath("${params.input_folder}/${params.bam_file_prefix}.bam")
    .ifEmpty { exit 1, "${params.input_folder}/${params.bam_file_prefix}*.bam not found.\nPlease specify --input_folder option (--input_folder bamfolder)"}
    .map { bam -> tuple(bam.baseName, bam) }

bai = Channel
    .fromPath("${params.input_folder}/${params.bam_file_prefix}.bam.bai")
    .ifEmpty { exit 1, "${params.input_folder}/${params.bam_file_prefix}*.bam.bai not found.\nPlease specify --input_folder option (--input_folder bamfolder)"}

ref = Channel
		.fromPath(params.ref)
		.ifEmpty { exit 1, "${params.ref} not found.\nPlease specify --ref option (--ref fastafile)"}

sonic = Channel
    .fromPath(params.sonic)
    .ifEmpty { exit 1, "${params.sonic} not found.\nPlease specify --sonic option (--sonic sonicfile)"}

// Header log info
log.info """=======================================================
		TARDIS
======================================================="""
def summary = [:]
summary['Pipeline Name']    = 'TARDIS'
summary['Bam file']         = "${params.input_folder}/${params.bam_file_prefix}*.bam"
summary['Bam index file']   = "${params.input_folder}/${params.bam_file_prefix}*.bam.bai"
summary['Sonic file']       = params.sonic
summary['Reference genome'] = params.ref
summary['Output dir']       = params.outdir
summary['Working dir']      = workflow.workDir
log.info summary.collect { k,v -> "${k.padRight(15)}: $v" }.join("\n")
log.info "========================================="

process tardis {

	publishDir "${params.outdir}", mode: 'copy'

	input:
  set bam_name, file(bam) from bam
  file bai from bai
	file ref from ref
	file sonic from sonic

	output:
	file('*') into results

	script:
	"""
  tardis \
  --input $bam \
  --ref $ref \
  --sonic $sonic \
  --output $bam_name
	"""
}

workflow.onComplete {
	println ( workflow.success ? "\nTARDIS is done!" : "Oops .. something went wrong" )
}