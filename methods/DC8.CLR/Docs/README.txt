#------------------------------------------------
CONTEXT LIKELIHOOD OF RELATEDNESS: A QUICK HOW-TO
#------------------------------------------------

Version 1.2  Released on August 15th, 2007
Updated to v. 1.2.2 on 3/15/20010

Table of Contents

0. What's new in 1.2.2
1. Introduction
2. Licensing
3. Installation
   a. Platform-specific components
      1) Windows
      2) Linux
   b. MATLAB components
4. Scripts
   a. CLR algorithm
   b. Visualisation & analysis scripts
   c. Other scripts
5. Data files
6. Examples
7. Support

#--------------
0. What's new in 1.2.2

This version, like v.1.2.1, contains several bug fixes.  Most notable changes:
a. the old version's command line script computed false discovery rates incorrectly
b. the matlab tool for computing histograms, which was also useful for computing appropriate bin counts, was broken and gave incorrect results when the input dataset contained multiple variables
c. some internal library code was re-written to be a little faster and to support some ongoing projects at the Applied Biodynamics Lab at BU

1. Introduction

This document describes installation and usage of Context Likelihood of Relatedness (CLR), a gene network reconstruction method described in the included CLR manuscript (Faith, Hayete et al, PLoS Biology 1/2007).  Please refer to the publication for more information about the theory of the method.  For most of the scripts included in the distribution, type "help scriptname" in Matlab for additional usage information.  Command-line utilities will print usage information when started without any parameters.  This document describes how to install and use CLR on most systems.  Additional queries about the algorithm should be directed to Dr. Timothy Gardner (tgardner@bu.edu).

The main CLR utitilities, as well as some of the more useful tools used in the paper, are included in the Code/ directory of this distribution.  InfoKit2 sub-directory contains some miscellaneous tools such as command-line CLR, the mex file for the mutual information utility, as well as the C sources for all the executables and mex files in the distribution.

#-----------
2. Licensing

The CLR algorithm may be used free of charge for non-commercial purposes.  For commercial use, contact Dr. Timothy Gardner at Boston University (tgardner@bu.edu).

#----------
3. Installation

All scripts are meant to be run from the Code/ directory of the distribution, and this directory needs to be added to the Matlab path to suse the supplied .mex files.  For more advanced use, such as modifying the sources or buliding to alternative platforms (e.g. Mac), please read the following comments.  These suggestions are known to work for Matlab 7.  On Windows, Matlab 7.1 may be required for some utilties to work, owing to some mex/linking changes in that version.  Since earlier versions of Matlab 7 (R 14) suffered from fairly severe bugs on various platforms, we recommend using the Service Pack 2 or even 3 (v. 7.1) or later release of the product.


Comments on installation:

a. Platform-specific components
   
CLR initially relied on an external library which estimates mutual information by B-spline smoothing of bin weights.  

For more information or to download that library, refer to:
http://www.biomedcentral.com/1471-2105/5/118
and
http://sonnhammer.cgb.ki.se/carsten/mi.html

Since version 1.1, we have been providing a different version of spline mutual information which provides nearly identical outputs but:
* works with single-typed data internally, which saves RAM on certain CPU architectures
* runs about 2x-3x faster per CPU
* supports cluster parallelization (you specify which columns to compute) (interface not included in this release)
* does not, however, run in threaded mode in order to be compatible with Windows without having to maintain multi-platform code

This version was lifted from the web, fixed (it was broken), modified with certain options, and is distributed here.  See source for credits.

Any other implementation of mutual information may be used.  The spline approach was found to produce reliable results efficiently.  Until we see something better in both speed and quality, that's what we recommend.

That said, a number of other packages are available online.

The platform specific situation for compiling the libraries in this release is as follows:
1) Windows

Command-line clr utility (clr.exe), found in Code/, compiles under Cygwin (and ONLY under Cygwin) but doesn't need the whole of Cygwin to run (runtime dlls are included here).  

Matlab tools build from Matlab on any platform, as matlab comes with a stripped-down ansi c compiler (lcc).

The included windows mex files were compiled under a 32-bit version of Windows XP.  Under the 64-bit Windows, you may have to recompile the mex files from scratch, possibly omitting some or all of optimization flags (we've seen some issues with the 64-bit lcc compiler bundled with Matlab).

In addition, mi.c, the MEX interface, supports both SINGLE and DOUBLE inputs and returns SINGLE output, while other functions accept DOUBLE and return SINGLE.  SINGLE input support may be added to other mex files in the future.

2) Linux

This is our native development platform.  No known problems.

3) For both Windows and Linux platforms, the Matlab (.mex) utilities can be built using makeMex.m in InfoKit2 directory.  The mex files for Linux 32 and Windows 32 are provided.  The command-line (.exe) tools can be built in the same directory by running 'make "platform"', where platform is one of 'cygwin', 'linux32', or 'linux64'.

b. MATLAB components

Code/, the directory containing the Matlab scripts and libraries must be located in the matlab path, or else it must be the current working directory.  Data/ directory, which may be available as part of this download (internally) or as a separate download (externally), should be in the path if one is to work with utilities that require it.

Sources are located in Code/InfoKit2/ and are not required for typical use of the library.

#---------
4. Scripts

For usage syntax, refer to help included in the script file (type 'help scriptname' in matlab).

a. The CLR algorithm

+ clr.m

Accepts data matrix and three parameters; returns connectivity and mutual information matrices.

Data matrix may be either one of gene expression matrix or mutual information matrix.  
If the input matrix is symmetric with respect to transpose (which implies being square, too) then the input is assumed to be a mutual information matrix, 
and the subsequent computation of MI-matrix is skipped.

Method may be 'normal', 'rayleigh', or a few others (see help).  Rayleigh method specifically produces nice fits on smaller networks, but its p-values become too small for calculation as the network approaches genome scale.  For large networks, we use 'normal' or 'stouffer' methods.  Other methods are included for testing and reference.

To reiterate, for small networks (< 2000 genes), Rayleigh is usually the more robust method, and may be used reliably on as few as 1200 genes, and perhaps even fewer.  Normal input method works best with 2000+ genes to fit.

The n and k parameters are the number of bins and the spline degree, and they are passed directly to the mutual information routine.

ALL NETWORK METHODS RETURN Z-SCORES.  THE SUPPLIED UTILITY, FDR.m, WILL CONVERT Z-SCORES ON THE FLY FOR SIGNIFICANCE TESTING.

b. Visualization and analysis scripts

+ findThreshold.m
For the supplied E. coli data ONLY, this script finds a threshold corresponding to a desired precision.  

FOR E. COLI DATA, IT PRODUCES UNRELIABLE RESULTS SOMEWHAT ABOVE 80%, since the precision/sensitivity curve is erratic at
low sensitivites due to smaller sample sizes, and the script uses local (binary) search for the threshold.  Where the script fails 
depends mainly on where the network becomes sparse.

+ FDR.m
Significance threshold estimator based on False Discovery Rate.  Works with square matrices of z-scores (and, obviously, vectors of p-values).

+ mapGenes.m (& gDisplay.m)
High-level and low-level wrappers for GraphViz.  Most people will never use gDisplay.m directly.  Refer to demo for usage; also see example section below.  You need to have GraphViz installed.

+ netSubsample.m 
Determine network reconstruction efficiency by subsampling, pursuing most efficient, random and least efficient strategies.  Refer to help section in the scriptfor details

+ sigMI, sigRoulston - two other methods to determine significance of mutual information - by permutation, and analytically, respectively.  Both methods measure inherent co-occurrence significance, not network (context) significance.

+ matrixPvalue.m (& matrixCompare.m)
High-level and low-level analysis of a matrix vs control.  E.g.,

[prec, sens, spec, pval] = matrixPvalue(A1, A2, A3, ..., Atruth, ntf, [start, incr, finish, percent cutoff]);

plots a variety of diagnostic charts comparing maps A1-An against Atruth, where each map has only ntf (# of transcription factor) non-zero columns.  Each map is represented by a genes x genes matrix, with columns not corresponding to transcription factors zeroed out.  The ntf parameter is used for p-value calculations, and is important in that context.  Other parameters: start - bottom percentile for edge strength, incr - percentile increment, finish - percentile ceiling, percent cutoff - do not display the map below a certain accuracy.

For instance,

[prec, sens, spec, pval] = matrixPvalue(smallMap, reg_b3.Atest, 153, 98, 0.01, 100, 10);

will plot several charts for comparing smallMap (a submap of genes in regulon predicted by a certain algorithm) with Regulon being the 'truth', for top 2% of the edges with step of 0.01, and truncate the ROC-like chart (precision vs sensitivity) at 10% precision.

Note that smallMap has to be equivalent to reg_b3.Atest and should NOT contain the diagonal (self-regulation).  Non-transcription-factor columns should be zeroed out!  (See demo for an example)

The charts are:
P-value vs threshold (not too useful, since Matlab quickly falls prey to underflow)
ROC curve (sensitivity vs 1-specificity), also useless, since knowledge of TFs makes every algorithm looks good, even the random one.
Sensitivity vs 1-sparsity (mainly for troubleshooting)
Sensitivity at a given percentile (mainly for troubleshooting)
Precision vs sensitivity (most useful of them all).

+demo.m
The demo file.  Supports these modes:

a. demo('regulon')

Compares every mode of distribution fitting supported by clr on a small (regulon-sized) network.  Networks will be worse for being so small (not enough background) but it is nice to see how they stack up, even approximately.

b. demo('plos') 

This shows how to retrace the steps of the PLoS 07 paper.  The results will be slightly different since there is more data now, it is more biased than before, and the algorithm has changed.

c. demo('misc') 

Miscellaneous tool usage examples for other tools in this distribution.



#----------
5. Data files - distributed separately on the same website

These files are not needed to run CLR.  They are provided for reference to the manuscript and for trying out the algorithm.

+ compendium.mat

This large file is available from the web page separately from the code distribution.  It contains the entire set of E. coli gene expression data described in the manuscript.  The 'gidx' field describes ORFs annotated with a blattner id.

+ map_normal.mat

Contains the CLR Z-score matrix for E. coli.  Computed using the compendium.mat RMA normalized data.

+ reg.mat

All TF -> Gene interactions obtained from RegulonDB 4.0

The fields with the 'test' suffix were used for the PLoS paper.  E.g., the 'test' matrix does not contain any self-regulation.


+ tfs.mat

The file containing the list of known and putative transcription factors in E. Coli.  This is a superset of the tfs in reg.mat.  The indices with the suffix of _4345 point into the rows of the expression matrix in compendium.mat corresponding to the blattner id set.  The _7312 suffix describes the tfs in the 1:7312 indexing range (all probes).

#----------
6. Examples

See demo.m for examples of usage.  Most utilities have good help notes.  Type 'help <utility>' in the Code/ directory.

#----------
7. Support

Are you kidding?  OK, if your questions are not addressed in the manuscript and you're nice, we'll give you a helping hand.  Please inform us of problems with this distribution.

