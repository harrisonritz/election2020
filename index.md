# election 2020: The great model face-off

I’ve built this website to compare how well [538](https://projects.fivethirtyeight.com/2020-election-forecast) and [The Economist](https://projects.economist.com/us-2020-forecast/president) predict the election results. 

I'm NOT all that interested in which famous statistician ‘wins the day’, however I AM really interested in how the assumptions we make in models play out in real-life (and high-stakes) scenarios. There has been a lot of [discussion](https://statmodeling.stat.columbia.edu/2020/10/24/reverse-engineering-the-problematic-tail-behavior-of-the-fivethirtyeight-presidential-election-forecast/) on the relative merits of each model, focused mostly on shape of the distribution (whether a model included 'fat tails' that allow for a possibility of large upsets), and how to best model the correlation across states (E.g., when and where its reasonable to assume low or negative correlations across states). 

These assumptions make a big difference, because they shape the narrative of what we expect come election night.

**On Tuesday, I'll compare the performance of these two models as the results come in**, seeing how well the models predict the democratic vote share in each state. While election night will be winner-take-all, predicting the actual vote shares allows for a finer-grained comparison of these models (e.g., they both predict the same outcomes: a Biden presidency).


Election Comparison
------------

TBD



Initial model Comparison
------------

First, let's look at the outcomes each model predicts at the state level, ignoring the correlation across states.

In all of the graphs, **538** will be plotted in BLACK, and **The Economist** will be plotted in RED.


![state mean field](/figures/meanfield.png)

What's immediately clear from this figure is that The Economist is a lot more confident in their predictions -- they have a very peaked distribution around their expected vote share. In contrast, 538 has a longer-tailed distribution, making less precise predictions, but accommodating unexpected results. Despite those differences, the models are predicting very similar results, especially for who will win the night.

Stronger differences between the models come from when we look at their multivariate predictions, how they expect the results in one state to depend on the others.

First let’s look at how they expect the results in different states to correlate with each other.

![state correlations](/figures/corrplots.png)

Two things jump out at me there. First, the state correlations in 538 cover a much broader range, including negative correlations, whereas The Economist only models positive correlations between states. Second, the correlations in 538 are unimodal and skewed, whereas The Economist appears to have a bimodal distribution. I’d bet that the bimodal distributions for The Economist come from ‘republican’ vs ‘democrat’ states, but this would be something to look into further.



