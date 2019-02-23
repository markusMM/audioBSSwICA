# Audio BSS with ICA

This project is a proof of concept for the unsupervised (blind) separation of two audio sources captured from the same scene with K channels.

We are here using the Maximum Likelihood Estimation MLE given a Cauchy in each frequency bin. This funktion shall model the super Gaussian behaviour of the speech.

Generally in the folder "DSPII_ICA" all necessary methods and funtions, with proper comments, can be found to even build your own MLE!

The MLE is calculated through gradient ascend of the Likelihood (it could also be the gradient descend of the inverse likelihood, I don't quite remember..).

We can make use of the natural gradient and the normal gradient methods. Generally the natural gradient seems to be more calculation intense.

Unfortunately, those methods are not separated, like the other methods in this package. Anyways many different gradient descent techniques do exist and there are plenty of optimization methods (like Adam) which could efficiently train this model.

Since, this was a proof of concept and might be better transformed into Python for more utility, it does not have that many optimizations. Even in the sample files, frequency bins might not be used very well. This is one reason, why I changed the dimensionality of the output figures of the example.

But really it makes a lot of sense exploring the "DSPII_ICA" folder yourself! There are a lot of useful functions for exploratory data analysis for acoustic / time series data ^^"

A few nice ones to mention are:
-kurt.m for the curtosis
-konv.m for convolution of two time series (also as an even faster version, ... )
-ovadd.m to reconstruct a signal previously windowed into several frequency bins


## Example

As an example we have two 2 channel spoken stereo signals overlapped (see ... * or better hear * "audio/160318_02.WAV"). For the original setup we also once recorded our own signals with two microphones, but the results were terrible and the recodings quite large xP

I have to mention here, that we did not measure special frequency metrics, like MFCCs, and did not try to dereverberate the audio as part of the preprocesing! -> This is, why the standard audio signals do work much better than recorded signals!

We can take a look at the spectogramms of the signals before and after the separation and the log-likelihood of the ICA MLE below.

![some replacement text for the spectograms](https://github.com/markusMM/audioBSSwICA/raw/master/figures/SpecBSS_Lreverb.png)

![some replacement text for the log-likelihood](https://github.com/markusMM/audioBSSwICA/raw/master/figures/logLikelihoodBSSf_Lreverb.png)

If you want to find out how well this reconstruction listens, try the "main_BSS.m" scipt yourself! It will play you the results at the end after a few beeps ^^!

## Credits
Markus Meister : university of Oldenburg (Olb) - Division for Machine Learning (H4A) (former student worker)
<meister.markus.mm@gmx.net>
Jakob Drefs : university of Oldenburg (Olb) - Division for Machine Learning (H4A)
<jakob.heinrich.drefs@uol.de>
Prof. Dr. Jörg Anemüller : university of Oldenburg (Olb) - Division for Signal Processing and Acoustics (H4A)

## Final Note
ATM this repo is WIP, 
so please wait for the full adaptation to GIT!
