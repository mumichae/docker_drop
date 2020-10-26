# The Docker image for DROP (Detection of RNA Outlier Pipeline)

DROP is intended to help researchers use RNA-Seq data in order to detect genes with aberrant expression, aberrant splicing and mono-allelic expression. It consists of three independent modules for each of those strategies. After installing DROP, the user needs to fill in the config file and sample annotation table (Preparing Input Data). Then, DROP can be executed in multiple ways (Executing the Pipeline).

A detailed description of the DROP pipeline can be found on the [protocol exchange server](https://protocolexchange.researchsquare.com/article/993ff4a5-38ce-4261-902a-600dbd528ba2/v1).

Further information can be optioned from the [DROP documentation](https://gagneurlab-drop.readthedocs.io/en/latest/).

# The DROP image

The docker image uses conda to manage the environment and installs all its dependencies through `bioconda` and `conda-forge`. 

I has all dependencies already preinstalled. Mainly:

* [DROP](https://github.com/gagneurlab/drop)
* [OUTRIDER](https://github.com/gagneurlab/OUTRIDER)
* [FRASER](https://github.com/gagneurlab/FRASER)
* [tMAE](https://github.com/mumichae/tMAE)
* [snakemake](https://snakemake.readthedocs.io/en/stable/)
* [wbuild](https://github.com/gagneurlab/wBuild)
* [GATK](https://gatk.broadinstitute.org/hc/en-us)
* [bcftools](http://samtools.github.io/bcftools/bcftools.html)


## Building the Docker image

```
git clone git@github.com:c-mertes/docker_drop
docker build . --network=host --build-arg DROP_VERSION=1.0.0 --tag mertes/drop:1.0.0 --tag mertes/drop:latest --tag mertes/drop
```

## Using the Docker image

### The demo dataset

Running the example pipeline is straight forward.
1. Spinning up the docker image
2. Initializing the demo repository
3. Run the DROP pipeline
4. Look at results

```
# spin up the docker image with www connection
docker run --rm --network=host -ti mertes/drop

# init and run demo inside docker
drop demo
snakemake --cores 2 --jobs 2

ls -la Output
```

### Using your own data (mounting)

If the user wants to mount his own data into the image, we have to make sure all the pathes are correct.

DROP uses the `Data/sample_annotation.tsv` to lookup the corresponding BAM and VCF files. Those pathes have to match the docker image structure so drop can find them. This is in the users responsibility. Furthermore the user has to make sure that docker can read and write any file and folder within the mounted folders.

As an example we assume following structure on the host:

```
- $HOME/drop_project # project root
  - /analysis        # analysis repo
  - /output          # Output folder of full analysis including html output
  - /raw_data        # raw data dir
    - /vcf_files     # all VCF files
    - /rna_files     # all RNA-seq files
```

Mapping this to the docker image we will have the following structure 

```
- /drop/             # project root
  - /analysis        # analysis repo
  - /output          # Output folder of full analysis including html output
  - /raw_data        # raw data dir
    - /vcf_files     # all VCF files
    - /rna_files     # all RNA-seq files
```

With this structure we could now run drop with our private user from the host as follows:

```
# run on your host system
PROJ_ROOT=/$HOME/drop_project
docker run --rm -ti \
	-v "$PROJ_ROOT/analysis:/drop/analysis" \
	-v "$PROJ_ROOT/output:/drop/output" \
	-v "$PROJ_ROOT/raw_data:/drop/raw_data" \
	-u "`id -u`:`id -g`" \
	mertes/drop snakemake --cores 2 --jobs 2

ls -la $PROJ_ROOT/output
```

