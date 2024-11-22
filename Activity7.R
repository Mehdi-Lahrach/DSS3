



#01.Data Exploration

#Load Libraries

library(lme4)
library(tidyverse)

#Load Data

data("sleepstudy")
?sleepstudy

# Explore Structure

head(sleepstudy)
summary(sleepstudy)

# Remove day 0 and day 1, should not be included in analysis 

sleepstudy <- sleepstudy %>%
  filter(Days > 1) 

head(sleepstudy)

#instead of keep using the Days variable that starts from 2 we will code a variable 
#that is easy to interpret 

sleepstudy <- sleepstudy %>% 
  mutate(days_deprived = Days - 2)

head(sleepstudy)

# Visualize 

histg <- ggplot(sleepstudy, aes(x = Reaction)) +
  geom_histogram() +
  theme_minimal()
ggsave(filename = "histogram of reaction time.png", plot = histg, width = 8, height = 6, dpi = 300)


ggplot(sleepstudy, aes(x = as.factor(days_deprived), y = Reaction)) + 
  geom_point() + 
  labs(y = "Reaction Time in MS", x = "Days 0-9") +
  theme_minimal()



#02. Descriptive Statistics

range(sleepstudy$Reaction)
range(sleepstudy$Days)

mean(sleepstudy$Reaction)


p <- ggplot(sleepstudy, aes(x = as.factor(days_deprived), y = Reaction, group = Subject, color = as.factor(Subject))) +
  geom_line(size = 1) +  
  geom_point(size = 3) +
  labs(
    title = "reaction time over days",
    x = "days",
    y = "reaction time ms",
    color = "subject"
  ) +
  theme_minimal() 
ggsave(filename = "reaction_time_over days_plot.png", plot = p, width = 8, height = 6, dpi = 300)



#checking baseline for each subject 

p2 <- ggplot(sleepstudy, aes(x = as.factor(days_deprived), y = Reaction)) +
  geom_line() +
  geom_point() +
  facet_wrap(~ as.factor(Subject)) +
  labs(
    title = "Reaction time ver days for each subject",
    x = "days",
    y = "reaction time ms",
    color = "subject"
  ) +
  theme_minimal()
ggsave(filename = "Reaction time ver days for each subject.png", plot = p2, width = 8, height = 6, dpi = 300)


#With only one exception (subject 335) it looks like reaction time increases 
#with each additional day of sleep deprivation


#03 fitting models

#lets fit a model that estimates a single intercept and slope for the entire dataset, ignoring the 
# the fact that different subjects might vary in their intercepts or slopes.

general_model <- lm(Reaction ~ days_deprived, sleepstudy)
summary(general_model)

#According to this model, the predicted mean response time on Day 0 is about 
#245 milliseconds, with an increase of about 11 milliseconds per day of deprivation, on average.

#we are assuming that all of the observations are independent 
#However, we can be pretty sure this is a bad assumption.

#lets visualize

ggplot(sleepstudy, aes(x = days_deprived, y = Reaction)) +
  geom_abline(intercept = coef(general_model)[1],
              slope = coef(general_model)[2],
              color = 'blue') +
  geom_point() +
  scale_x_continuous(breaks = 0:7) +
  facet_wrap(~Subject) +
  labs(y = "Reaction Time", x = "Days deprived of sleep basline (2)")


#model fits the data badly. We need a different approach.

# after the basic model we understand now that we need a unique intercept and  slope for each subject 
#To do so we can use mixed effect models


lme_mod <- lmer(Reaction ~ days_deprived + (days_deprived | Subject), sleepstudy)

summary(lme_mod)

#before interpret the output, let's first plot the data against our model predictions.

# Extract fitted values
sleepstudy$fitted <- predict(lme_mod)

# Plot observed data and fitted lines for each subject
p3 <- ggplot(sleepstudy, aes(x = days_deprived, y = Reaction)) +
  geom_point() +
  scale_x_continuous(breaks = 0:7) +
  facet_wrap(~Subject) +
  geom_line(aes(y = fitted), color = "blue", size = 0.5) +  # Fitted values
  labs(
    title = "Reaction Time vs. Days of Sleep Deprivation",
    x = "Days of Sleep Deprivation",
    y = "Reaction Time (ms)"
  ) +
  theme_minimal() +
  theme(legend.position = "none")  # Hide legend for cleaner visualization
p3
ggsave(filename = "Reaction Time vs. Days of Sleep Deprivatiofited.png", plot = p3, width = 8, height = 6, dpi = 300)


#The model shows that reaction time increases by 11.435 ms per day of sleep 
#deprivation on average, and this effect is statistically significant.
#Subjects have significant variability in their baseline reaction times (SD = 30.96 ms) and their responses to sleep deprivation (SD = 6.77 ms)























