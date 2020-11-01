# election 2020: The great model face-off

I’ve built this website to compare how well [538](https://projects.fivethirtyeight.com/2020-election-forecast) and [The Economist](https://projects.economist.com/us-2020-forecast/president) predict the election results. 

I'm NOT all that interested in which famous statistician ‘wins the day’, however I AM really interested in how the assumptions we make in models play out in real-life (and high-stakes) scenarios. There has been a lot of [discussion](https://statmodeling.stat.columbia.edu/2020/10/24/reverse-engineering-the-problematic-tail-behavior-of-the-fivethirtyeight-presidential-election-forecast/) on the relative merits of each model, focused mostly on shape of the distribution (whether a model included 'fat tails' that allow for a possibility of large upsets, and how to best model the correlation across states. These assumptions make a big difference, and share the narrative of how we expect each candidate to perform on election night.

**On election night, I'll compare the performance of these two models as the results come in**, seeing how well the models predict the democratic vote share in each state. While election night will be winner-take-all, predicting the actual vote shares allows for a finer-grained comparison of these models (e.g., they both predict the same outcomes: a Biden presidency).



Inital model Comparision
------------

First, lets look at what each model predicts at the state level, ignoring the correlation across states.

![mean field](/figures/meanfield.png)
