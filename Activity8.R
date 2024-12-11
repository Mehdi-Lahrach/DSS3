# Load necessary libraries
install.packages("maps") # Install maps package if not already installed
install.packages("tidyverse") # For data manipulation and visualization
install.packages("broom") # For tidying regression results
install.packages("scatterplot3d") # For creating 3D scatterplots

library(tidyverse)
library(broom)
library(maps)
library(scatterplot3d)

# Load and inspect data
clim <- read.csv("https://userpage.fu-berlin.de/soga/data/raw-data/Climfrance.csv", sep = ";")
str(clim)
View(clim)

# Clean data: Fix altitude and precipitation variables
# These variables are stored as text with commas
clim$altitude <- gsub(',', '', clim$altitude) # Remove commas
clim$p_mean <- gsub(',', '', clim$p_mean) # Remove commas

# Convert to numeric
clim$altitude <- as.numeric(clim$altitude)
clim$p_mean <- as.numeric(clim$p_mean)

# Verify changes
str(clim)

# Fix encoding issues for station names because of french language characters not supported with R 
# Modify station names manually to ensure correct rendering
clim[16, "station"] <- "Montelimar"
clim[18, "station"] <- "Sete"
clim[21, "station"] <- "Strasbourg"

# Plot: Map of climate stations in France
france_map <- map_data("france")

climate_plot <- ggplot() +
  # Add France map
  geom_polygon(data = france_map, aes(x = long, y = lat, group = group), fill = "gray90", color = "black") +
  # Add climate stations
  geom_point(data = clim, aes(x = lon, y = lat, color = t_mean), size = 3) +
  # Add station names
  geom_text(data = clim, aes(x = lon, y = lat, label = station),
            hjust = 0.2, vjust = -0.5, size = 3) +
  # Customize color scale for mean temperature
  scale_color_viridis_c(option = "C", name = "Mean Temp (°C)") +
  # Labels and theme
  labs(
    title = "Climate Stations in France",
    x = "Longitude",
    y = "Latitude"
  ) +
  theme_minimal() +
  theme(legend.position = "right")

climate_plot

# Save the plot
ggsave(filename = "map.png", plot = climate_plot, width = 10, height = 7, dpi = 300)

# Prepare data for analysis: Exclude invalid rows
climffrar <- clim[1:34, ]
View(climffrar)

# Exercise 1: Multiple Linear Regression
mat_mdl <- lm(t_mean ~ altitude + lat + lon, data = climffrar)

# Summarize and tidy the regression results
tidy(mat_mdl) %>% 
  mutate(
    p.value = format.pval(p.value, 4),
    estimate = round(estimate, 2),
    std.error = round(std.error, 2),
    statistic = round(statistic, 2)
  )

# # A tibble: 4 × 5
# term        estimate std.error statistic p.value  
# <chr>          <dbl>     <dbl>     <dbl> <chr>    
#   1 (Intercept)    37.3       2.62     14.2  7.287e-15
# 2 altitude       -0.01      0        -7.38 3.173e-08
# 3 lat            -0.53      0.06     -9.58 1.240e-10
# 4 lon             0.03      0.04      0.81 0.4236   

# Interpretation:
# - Longitude (lon) is not significant (p-value = 0.4236), so we exclude it in the next model.
# - Altitude and latitude are highly significant (p-values < 0.001), meaning they have a strong relationship with mean temperature.
# - The negative coefficients for altitude (-0.01) and latitude (-0.53) suggest that higher altitudes and moving north (higher latitude) result in lower temperatures. This aligns with geographic and climatic principles.

# Expanded Insight:
# Longitude's insignificance likely reflects France's relatively small range in longitude compared to latitude. Thus, east-west differences are minimal in explaining temperature variation.

# Exercise 2: Refined Model Excluding Longitude
mat_mdl2 <- lm(t_mean ~ altitude + lat, data = climffrar)

# Predictions for specific stations
mont_ventoux <- clim[clim$station == 'Mont-Ventoux', c('lat', 'altitude')]
mont_ventoux

pic_du_midi <- clim[clim$station == 'Pic-du-Midi', c('lat', 'altitude')]

predict(mat_mdl2, newdata = mont_ventoux) # Predicted temperature for Mont-Ventoux
predict(mat_mdl2, newdata = pic_du_midi) # Predicted temperature for Pic-du-Midi

# Interpretation:
# - The predicted temperatures reflect the influence of both altitude and latitude on climate.
# - Mont-Ventoux: Located at a higher altitude and latitude, it exhibits a lower mean temperature.
# - Pic-du-Midi: Similarly affected by altitude, the model confirms the cooling effect of elevation.

# Expanded Insight:
# These predictions underscore the strong explanatory power of the refined model, as it captures realistic climatic patterns. Minor deviations from actual values could arise from unmodeled factors like wind patterns or local microclimates.

# Exercise 3: 3D Scatterplot with Regression Plane

#save plot
#png("3D_scatterplot_with_plane.png", width = 800, height = 600)

# Create a 3D scatterplot
s3d <- scatterplot3d(
  climffrar$altitude,          # X-axis
  climffrar$lat,               # Y-axis
  climffrar$t_mean,            # Z-axis
  angle = 55,                  # Viewing angle
  main = "3D Scatterplot with Regression Plane",
  xlab = "Altitude (m)",
  ylab = "Latitude (°N)",
  zlab = "Mean Annual Temperature (°C)",
  pch = 19,                    # Solid circle for points
  color = "blue",              # Point color
  grid = TRUE,
  box = FALSE
)

# Add the regression plane to the plot
s3d$plane3d(mat_mdl2, draw_lines = TRUE, lty = "dotted")


#dev.off()

# Summarize the final model
summary(mat_mdl2)

# Expanded Interpretation:
# - (R^2 = 0.83): The model explains 83% of the variability in mean temperature. This high value indicates the strong influence of altitude and latitude.
# - Residual standard error: Suggests a typical prediction error of about 0.7°C, which is quite low for temperature models.
# - Significant predictors: Both predictors are critical, reflecting the substantial role of spatial factors in determining climatic conditions.

# Summary: The refined model captures realistic climatic trends in France, with strong predictive accuracy. Future models could integrate additional variables, like precipitation, for even better predictions.
