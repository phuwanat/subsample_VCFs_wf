version 1.0

workflow subsample_VCFs {

    meta {
	author: "Phuwanat Sakornsakolpat"
        email: "phuwanat.sak@mahidol.edu"
        description: "subsample VCF"
    }

     input {
        File vcf_file
        File tabix_file
        File sample_file
    }

    call run_subsampling { 
			input: vcf = vcf_file, tabix = tabix_file, sample=sample_file
	}

    output {
        File subsampled_vcf = run_subsampling.out_file
        File subsampled_tbi = run_subsampling.out_file_tbi
    }

}

task run_subsampling {
    input {
        File vcf
        File tabix
        File sample
        Int memSizeGB = 8
        Int threadCount = 2
        Int diskSizeGB = 8*round(size(vcf, "GB")) + 20
	String out_name = basename(vcf, ".vcf.gz")
    }
    
    command <<<
	mv ~{tabix} ~{vcf}.tbi
	bcftools view -S ~{sample} -o ~{out_name}.subsampled.vcf.gz ~{vcf}
	tabix -p vcf ~{out_name}.subsampled.vcf.gz
    >>>

    output {
        File out_file = select_first(glob("*.subsampled.vcf.gz"))
        File out_file_tbi = select_first(glob("*.subsampled.vcf.gz.tbi"))
    }

    runtime {
        memory: memSizeGB + " GB"
        cpu: threadCount
        disks: "local-disk " + diskSizeGB + " SSD"
        docker: "quay.io/biocontainers/bcftools@sha256:f3a74a67de12dc22094e299fbb3bcd172eb81cc6d3e25f4b13762e8f9a9e80aa"   # digest: quay.io/biocontainers/bcftools:1.16--hfe4b78e_1
        preemptible: 2
    }

}
