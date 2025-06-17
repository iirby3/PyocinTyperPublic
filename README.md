# PyocinTyper
Type pyocins of *Pseudomonas aeruginosa*.

## Dependencies

**Nextflow**  
Install nextflow following the instructions at https://www.nextflow.io/docs/latest/getstarted.html

**cd-hit**  
Install cd-hit following the instructions at https://github.com/weizhongli/cdhit.

**Anaconda**  
This pipleine is enabled with conda. Install conda at https://anaconda.org/.  

All dependencies must be added to path.

## Installation
**Via github:**  
git clone git@github.com:GaTechBrownLab/PyocinTyper.git

**Via nextflow:** 
```bash 
nextflow pull GaTechBrownLab/PyocinTyper
```

## Usage

**Basic usage:**  
```bash
nextflow run main.nf -with-conda --pt_option <group|individual> --input_files = "./data/*.gbff" --outdir "/results"
```

## Documentation
```bash 
nextflow run main.nf --help
```