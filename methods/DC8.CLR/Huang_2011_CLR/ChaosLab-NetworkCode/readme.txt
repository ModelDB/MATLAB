#-------------------------- Title -------------------------
Comprehensive Mutual Information Method for Network Inference in HPN-DREAM sub1A
#-------------------------- Author ------------------------
The code was written by Xun Huang, (bioxun@gmail.com)
BIOSS Centre for Biological Signalling Studies University of Freiburg, 79104, Freiburg, Germany.

#---------------- Platform for execution ------------------
The program has been tested on Matlab R2011b 7.13, Windows 7 system. 

#------------------  Input and output ---------------------
inferNet_HPNexperiment_localrun.m is the main funtion for generating the required sif and eda file.
The inputs for the main function are files like MD_XXX_main.csv, which are specified by the variable "InFiles" in inferNet_HPNexperiment_localrun.m 

#------------- Overview of the methodology ----------------
In the first step, we generated a scored draft network (denoted as Net_draft) for each cell line using an approach that is based on time-lagged mutual information. We first obtained a network (denoted as Net_tlCLR) based on a time-lagged CLR (context likelihood relatedness)(Greenfield, et al., 2010, PLoS ONE) (We did some slight modification on this algorithm). In addition, we generated a second network (denoted as Net_tlMIg) based on the time-lagged mutual information inference. We took around 5 time series as a group, and selected 16 different groups. For each group, a time-lagged mutual information inference was applied. The ranked scores in all the groups are summed up to generate a score network, Net_tlMIg. Finally, we generated a draft network (Net_draft) by assigning the score of each link as the maximum score of the link in the ranked Net_tlCLR and ranked Net_tlMIg. 

In the second step, we generated a stimulus network (denoted as Net_stimu_stMI) for each stimulus using static mutual information inference method, which assumes the data at the time points of all the time series are in steady state. 

In the last step, we generated the final network matrix by summing up the ranked draft network (Net_draft) and the ranked stimulus network (Net_stimu_stMI). The Net_draft was assigned with higher weight than Net_stimu_stMI.

#------------- basics for dynamic learning -----------------
The basic idea of our dynamic learning is to infer the relation between explanatory vectors and response vectors (see (Greenfield, et al., 2010, PLoS ONE) for more details). In addition, we do not use the information of lengths of time intervals, in another word, all time intervals are consider equal in learning. 

#--------------------- supporting tools --------------------
The function for calculating mutual information was taken from CLR (context likelihood relatedness)algorithm(Faith, et al., 2007)[http://gardnerlab.bu.edu/software&tools.html]. 
The function for background correction in time-lagged CLR was also taken from CLR.
