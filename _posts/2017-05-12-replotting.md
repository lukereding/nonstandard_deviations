---
layout: post
title:  replotting three dimensional data
category: jekyll
description: alternatives to plotting three dimensional data in R
---

One of my favorite things to do when I read a paper is to replot the author's data in a way I like better. 

Sometimes my reasons are scientific. The bar plot reigns supreme over most academic papers I read, yet bar plots are usually used to hide information from the reader: by distilling a distribution of data into a single number, lots of information is lost. Other times, I just want to see whether I _can_ remake the author's plots, and if so, how fast I can do it. 

But sometimes I come across a figure that I instinctively don't like and want to come up with a better way of plotting it. Which is what happened in an airport waiting for an outboard flight out east over winter break. 

I started reading [this](http://rspb.royalsocietypublishing.org/content/283/1844/20161409) paper mostly because one of the authors is in my department and I wanted to see whether they could really use the term _behavioural hypervolumes_ seriously. (They can. Why they don't say 'variation in behaviors' instead is beyond me.) The authors measured the boldness (how long they took to start moving again after being scared), foraging aggressiveness, and overall activity levels of individuals from five spider species.

The author's challenge was coming up with a way to present three-dimensional data (the three variables they measured) on a two dimensional page. Here's the result:

![]({{site.baseurl}}/images/post1/fig1.png)

This is the sort of figure I cringe at. In their attempt to show all the data at once, the authors are sacrificing the ability of someone to actually take something meaningful away from the figure. Specifically, it's difficult for the reader to understand the foraging, activity, and boldness for each of the data points. 

Admittedly, you don't need to know the position in three-dimensional space of each data point to get the point the authors are trying to convey in the paper: the species apparently differ in the 'volume' of space occupied if you where to form a shape by connecting the most peripheral data points. Species that have lots of variation in their behaviors will have big 'hypervolumes'; species where there is little between-individual variation will have small 'hypervolumes'. Still, it's really difficult for the reader to judge, for example, the difference in the hypervolume size between the two species in the first column.

Can we plot it better? That's what I was wondering as a grappled with the Bingo hotspot to download the [data](http://datadryad.org/resource/doi:10.5061/dryad.ps383) from Dryad. 

### reading in the data

Let's first go ahead and read in the data. The data were provided as an Excel file; I saved it as a csv, cleaned up some of the column names, and renamed the file.

```r

# load packages
library(tidyverse)
library(magrittr)

# read in data, factoring species
df <- read_csv("~/Downloads/pruitt.csv")
df$species %<>% factor

# scale each variable to enable better visualization
df$activity %<>% scale
df$latency_to_attack %<>% scale
df$latency_to_resume_movement %<>% scale
```

Note that the `%<>%` is from the wonderful `magrittr` package is used to pipe the object on the left-hand side to the function on the right-hand side, and save the result of the function to the original object. `x %<>% factor` is shorthand for `x <- x %>% factor` or `x <- factor(x)`


### replot

An obvious first stab is to represent two of the variables by the x- and y-axes and a third by the color of the data points. 

```r

ggplot(df, aes(activity, latency_to_attack)) +
  geom_point(aes(color = latency_to_resume_movement)) +
  facet_wrap(~species) +
  scale_color_greens(name = "boldness") +
  theme_mod() +
  add_axes()

```

(I'm using a `ggplot` theme I like here, `theme_mod`, and some helper functions, like `add_axes()`, that are defined [here](https://github.com/lukereding/random_scripts/blob/master/plotting_functions.R).)

![]({{site.baseurl}}/images/post1/plot1.png)

This isn't the best plot but it shows the data, in, I think, a better way than the three-dimensional plot. Part of what we notice with this presentation is that most of the data points are purple: in other words, most of the spider measured are not  very bold. At least to me, this wasn't clear in the original plot of the data.

### a different approach

Is there a better way we can plot these data? This sort of dataset is not uncommon for biologists to want to visualize. One approach people have taken in the past, to better show the relationship between all three variables, is to use a surface plot. Though using a surface plot means we no longer are looking at the data and move to showing some abstraction of summary of the data, they can often be useful.

Below I should how we can use the `feilds` and `akima` packages  to create a function that returns a surface for each species. This amounts to estimating each species boldness for each combination of activity and latency of attack. I then apply that function to each species in the dataset and plot the result. This turns out to be a lot more readable, shorter, and more efficient than the approach I would have taken a year ago: create five subsets of data (one for each species), generate the surface for each, save each surface as a separate plot, then combine at the end.

First, we define a function that creates the surface for us:

```r

require(fields)
require(akima)
get.inter <- function(df){
  y <- with(df, interp(x = activity, 
                  y = latency_to_attack, 
                  z = latency_to_resume_movement))
  interp2xyz(y, data.frame=TRUE)
}

```

Then we using piping to (1) get the surface for each species and (2) plot the results all in one big step

```r


new_plot <- df %>%
  group_by(species) %>% # group by species
  nest %>% # this creates a column, data, with all the data from each of the five species
  mutate(
    inter = purrr::map(data, get.inter) # apply the get.inter() from above to each of the species
    ) %>%
  unnest(inter) %>% # unnest to get back a full data frame with all the results
  ggplot(aes(x = x, y = y)) + # set up out plot
  geom_raster(aes(fill = z)) + # provide a geom to use
  scale_fill_viridis(option = "B", name = "boldness") + # use a perceptually uniform color scheme
  facet_wrap(~species) + # make a separate plot for each species
  theme_mod() + # add a theme
  scale_color_continuous(na.value = "white") + # make NA values white
  labs(x = "activity", y = "foraging") + # add labels
  add_axes() # add axes

```

![]({{site.baseurl}}/images/post1/plot2.png)

In this presentation, other aspects of the dataset are emphasized. For example, for both the species in the left-most column, there are very bold individuals, but the bold individuals appeared to have different activity and foraging tendencies in the two species. It's important to note, though, that a lot of these trends are driven by a couple individuals, which the original replot shows. While abstractions like the surface plot are useful, they often hide information. I think it's actually easier with this type of plot to estimate the difference in 'hyper volumes' among the species.

We could improve on this point by actually layering the actual data on top of each of the surface plots. Luckily, `ggplot` makes this easy:

```r

newplot + geom_point(data = df, aes(x = activity, y = latency_to_attack), color = "white")

```

![]({{site.baseurl}}/images/post1/plot3.png)


…. to be continued…
