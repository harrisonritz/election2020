# election 2020: The great model face-off

I’ve built this website to compare how well [538](https://projects.fivethirtyeight.com/2020-election-forecast) and [The Economist](https://projects.economist.com/us-2020-forecast/president) predict the election results. 

I'm NOT all that interested in which famous statistician ‘wins the day’, however I AM really interested in how the assumptions we make in models play out in real-life (and high-stakes) scenarios. There has been a lot of [discussion](https://statmodeling.stat.columbia.edu/2020/10/24/reverse-engineering-the-problematic-tail-behavior-of-the-fivethirtyeight-presidential-election-forecast/) on the relative merits of each model, focused mostly on shape of the distribution (whether a model included 'fat tails' that allow for a possibility of large upsets), and how to best model the correlation across states (E.g., when and where its reasonable to assume low or negative correlations across states). 

These assumptions make a big difference, because they shape the narrative of what we expect come election night.

**On Tuesday, I'll compare the performance of these two models as the results come in**, seeing how well the models predict the democratic vote share in each state. While election night will be winner-take-all, predicting the actual vote shares allows for a finer-grained comparison of these models (e.g., they both predict the same outcomes: a Biden presidency).


Election Comparison
------------

TBD on tuesday!



Initial model Validation
------------

First, let's look at the outcomes each model predicts at the state level, ignoring the correlation across states.

In all of the graphs, *538* will be plotted in BLACK, and *The Economist* will be plotted in RED.


![state mean field](/figures/meanfield.png)

What's immediately clear from this figure is that *The Economist* is a lot more confident in their predictions -- they have a very peaked distribution around their expected vote share. In contrast, *538* has a longer-tailed distribution, making less precise predictions, but accommodating unexpected results. Despite those differences, the models are predicting very similar results, especially for who will win the night.

Stronger differences between the models come from when we look at their multivariate predictions, how they expect the results in one state to depend on the others.

First let’s look at how they expect the results in different states to correlate with each other.

![state correlations](/figures/corrplots.png)

Two things jump out at me there. First, the state correlations in *538* cover a much broader range, including negative correlations, whereas *The Economist* only models positive correlations between states. Second, the correlations in *538* are unimodal, whereas *The Economist* appears to have a bimodal distribution. I’d bet that the bimodal distributions for *The Economist* come from ‘republican’ vs ‘democrat’ states, but this would be something to look into further.


We can zoom into the correlations between a few states to see how these models differ at a finer-grained level.

![NE 538](/figures/compareMulti_538.png) 
![NE Economist](/figures/compareMulti_Econ.png)

Clearly, the *538* model is a lot noisier, allowing for surprising upsets. However, it is also noticeable how much weaker some of the correlations are between these states -- notice how different Rhode Island is from much of the rest of New England in *538*’s model relative to *The Economist*. These models seem to make very different predictions about the extent to which election outcomes are driven by local factors, reflected in how independent the noise is across states.


Model Recovery
--------------

Despite the differences between these models (especially at the multivariate level), it’s not totally clear whether they make *different enough* predictions that we’ll be able to compare them on election day. To test our ability to discriminate between these models, I compared the model likelihood of each model given data simulated from each model (i.e., model recovery). 

The model likelihoods for were calculated using multivariate kernel density estimation on the simulated vote shares from each model. I have a little discomfort about how to choose the bandwidth and kernel given the different assumption of these models (i.e., *538*’s fat tail). For the bandwidth, I landed on [Silverman’s Rule of Thumb](https://en.wikipedia.org/wiki/Kernel_density_estimation#A_rule-of-thumb_bandwidth_estimator) with min(STD, IQR), and for the kernel I used the Epanechnikov kernel, but confirmed that things looked similar with a t-distributed kernel.

Using these kernel likelihood functions, I compare the models’ likelihoods under both held-out simulations from the same model (e.g., P(*538* model ~ *538* sims), or under simulations from the alternative model P(*538* model ~ *Economist* sims). Since we have a lot of simulations, I just did one cross-validation fold (39k in-sample, 1k out-of-sample), but this is something I could spruce up with a k-fold cross-validation.

 ![model recovery](/figures/modelRecovery.png)

The top panel is a little complicated. Solid lines indicate that the model matched the data-generating process, and we can see that both models do a pretty good job, with the *Economist* have a higher likelihood under its own data (not surprising, given how peaked its predictions are). 

In the dashed lines, we can see the models’ likelihood under the *wrong* data-generating process, and this is where things get a little more interesting. Whereas the *538* model does pretty similarly whatever data it uses, we can see that the *Economist* model does quite poorly when data are generated from the fat-tailed *538* simulations (see: red dashed line). This is the downside of peaked predictions -- they’ll do great if they match the data-generating process, but will really suffer if things are noisier than they expect.

For our purposes, the bottom panel gives a better picture of whether we’ll be able to distinguish between these models. Here, I bootstrap sampled the model likelihoods, comparing the correct vs incorrect models (i.e., P(538 ~ 538) - P(Economist ~ 538)). What we can see is that the correct model for the data fits strictly better than the wrong model for the data. If the data is generated from a process that look more like the *Economist*, then the two models won't have dramatically different likelihoods (though likelihood ratios greater than 15 are pretty darn good). In contrast, if the data are generated from the *538* model, we’ll see a huge difference between these models.

This ability to select the correct model (i.e., pick the model that generated the data) gives us confidence that these models make different-enough predictions for us to compare them on election night. So let’s see what happens!
