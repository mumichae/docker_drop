# The Docker image for DROP

The docker image uses conda to manage the environment. 

It currently depends only on 3 external resources
* gagneurlab/wBuild
* gagneurlab/drop
* mumichae/tMAE

## Building the Docker image

```
git clone git@github.com:c-mertes/docker_drop
docker build . --network=host --tag mertes/drop:latest --tag mertes/drop
```

## Using the Docker image

```
docker run mertes/drop bash

mkdir drop_analysis
cd drop_analysis

snakemake -n
snakemake aberrantExpression --cores 2
snakemake aberrantSplicing --cores 2
snakemake mae --cores 2
snakemake --cores 2
```

## TODOS
* How to inject raw data from your local drive
* how to inject your project folder into the image
* How to store output outside the image
* Make sure that reruning the pipeline with docker does not recreate the files (aka time stamps!)

## Using the environemnt locally

To create a working environment for the drop analysis one has to run:

```
conda env create -f environment.yml
conda activate drop-docker
R -e 'devtools::install("mumichae/tMAE")' 
```
