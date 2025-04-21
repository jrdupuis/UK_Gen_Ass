# UK_Gen_Ass

Genome assembly, except not in very much detail and not in person because \<gestures generally\>. 

Software install info is provided in 00_dependencies.md, and then the steps of assembly and annotation are in order of our suggested process. 

Your MCC accounts should give you access to the `jdu282_s25genome_assembly` allocation (you should have gotten an email with info about that), and we have a working space here: `/pscratch/jdu282_s25genome_assembly`. You also have `/scratch` space for your own personal use, which will be `/scratch/[your linkblue]'. 

## Data
In `/pscratch/jdu282_s25genome_assembly` we have raw data for two insect assemblies, *Eudocima phalonia*, the fruit piercing moth, and *Acalolepta aesthetica*, an australian longhorn beetle which is now invasive in Hawaii. In general butterflies and moths have easy-to-assembly genomes and beetles have more difficult-to-assemble genomes, so we'd recommend starting with the moth. 

## Important!!
**Do not modify the raw data in the directories in pscratch!** That's for everyone to access and then copy into their own scratch space. So as you begin to work through these materials, create your own copy of those entire directories into your scratch. E.g., for me (jdu282 is my linkblue) I would do `cp -fr Acalolepta_aesthetica/ /scratch/jdu282/`. If you're unsure about how to do that, let Sheina or I know.
