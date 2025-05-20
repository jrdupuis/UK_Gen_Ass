# UK_Gen_Ass

Genome assembly, except not in very much detail and not in person because \<gestures generally\>. 

Software install info is provided in 00_dependencies.md, and then the steps of assembly and annotation are in order of our suggested process. 

Your MCC accounts should give you access to the `jdu282_s25genome_assembly` allocation (you should have gotten an email with info about that), and we have a working space here `/project/jdu282_s25genome_assembly/data` and here `/pscratch/jdu282_s25genome_assembly`. You also have `/scratch` space for your own personal use, which will be `/scratch/[your linkblue]'. 

## Data
In `/project/jdu282_s25genome_assembly/data` we have raw data for the Mexican fruit fly, which has recently been published here [here](https://academic.oup.com/g3journal/article/14/12/jkae239/7810958).

## Important!!
**Do not modify the raw data in the directories in /project!** That's for everyone to access and then copy into their own scratch space. So as you begin to work through these materials, create your own copy of those entire directories into your scratch. E.g., for me (jdu282 is my linkblue) I would do `cp -fr ./RawHiCData /scratch/jdu282/`. If you're unsure about how to do that, let Sheina or I know. **and no worries if you accidentally screw something up--just let us know and we can make a new copy!**
