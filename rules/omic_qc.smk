rule insertion_profile:
    input:
        "samples/star/{sample}_bam/Aligned.sortedByCoord.out.bam"
    params:
        seq_layout=config['seq_layout'],
    output:
        "rseqc/insertion_profile/{sample}/{sample}.insertion_profile.r",
        "rseqc/insertion_profile/{sample}/{sample}.insertion_profile.R1.pdf",
        "rseqc/insertion_profile/{sample}/{sample}.insertion_profile.R2.pdf",
        "rseqc/insertion_profile/{sample}/{sample}.insertion_profile.xls",
    conda:
        "../envs/rseqc_singularity.yaml"
    shell:
        "insertion_profile.py -s '{params.seq_layout}' -i {input} -o rseqc/insertion_profile/{wildcards.sample}/{wildcards.sample}"

rule inner_distance:
    input:
        "samples/star/{sample}_bam/Aligned.sortedByCoord.out.bam"
    params:
        bed=config['bed_file']
    output:
        "rseqc/inner_distance/{sample}/{sample}.inner_distance.txt",
        "rseqc/inner_distance/{sample}/{sample}.inner_distance_plot.r",
        "rseqc/inner_distance/{sample}/{sample}.inner_distance_plot.pdf",
        "rseqc/inner_distance/{sample}/{sample}.inner_distance_freq.txt",
    conda:
        "../envs/rseqc_singularity.yaml"
    shell:
        "inner_distance.py -i {input} -o rseqc/inner_distance/{wildcards.sample}/{wildcards.sample} -r {params.bed}"

rule clipping_profile:
    input:
        "samples/star/{sample}_bam/Aligned.sortedByCoord.out.bam"
    params:
        seq_layout=config['seq_layout'],
    output:
        "rseqc/clipping_profile/{sample}/{sample}.clipping_profile.r",
        "rseqc/clipping_profile/{sample}/{sample}.clipping_profile.R1.pdf",
        "rseqc/clipping_profile/{sample}/{sample}.clipping_profile.R2.pdf",
        "rseqc/clipping_profile/{sample}/{sample}.clipping_profile.xls",
    conda:
        "../envs/rseqc_singularity.yaml"
    shell:
        "clipping_profile.py -i {input} -s '{params.seq_layout}' -o rseqc/clipping_profile/{wildcards.sample}/{wildcards.sample}"

rule read_distribution:
    input:
        "samples/star/{sample}_bam/Aligned.sortedByCoord.out.bam"
    params:
        bed=config['bed_file']
    output:
        "rseqc/read_distribution/{sample}/{sample}.read_distribution.txt",
    conda:
        "../envs/rseqc_singularity.yaml"
    shell:
        "read_distribution.py -i {input} -r {params.bed} > {output}"

rule read_GC:
    input:
        "samples/star/{sample}_bam/Aligned.sortedByCoord.out.bam"
    output:
        "rseqc/read_GC/{sample}/{sample}.GC.xls",
        "rseqc/read_GC/{sample}/{sample}.GC_plot.r",
        "rseqc/read_GC/{sample}/{sample}.GC_plot.pdf",
    conda:
        "../envs/rseqc_singularity.yaml"
    shell:
        "read_GC.py -i {input} -o rseqc/read_GC/{wildcards.sample}/{wildcards.sample}"

