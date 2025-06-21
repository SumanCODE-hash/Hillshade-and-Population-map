Hillshade with Population Map using R
This repository contains a map visualization of Bangladesh that overlays 2020 population distribution (from WorldPop) with hillshade terrain relief generated using elevation data. Built entirely in R, this project demonstrates how to combine geospatial analysis and data visualization to create informative and aesthetically pleasing maps.

🗂️ Contents
Mapping.R – R script containing all code to load, process, and visualize the data

bd_pop_hillshade.png – Final rendered map as a high-resolution PNG

hillshade_df.csv – Hillshade data used for plotting (optional export)

README.md – You're reading it!

🚀 Getting Started
1. Clone the Repository
bash
git clone https://github.com/YOUR_USERNAME/Hillshade-with-population-map-using-R.git
cd Hillshade-with-population-map-using-R
2. Run Mapping.R in R or RStudio
Make sure you have the following packages installed:

r
install.packages(c("tidyverse", "raster", "sf", "ggplot2", "RColorBrewer",
                   "ggspatial", "terra", "geodata", "ggnewscale",
                   "elevatr", "scales"))
Then simply run the Mapping.R script to download the data, process it, and generate the map.

🗺️ Map Description
Population data is sourced from WorldPop's 100m constrained raster grid for Bangladesh (2020).

Elevation and hillshade are derived from SRTM-based DEM using the elevatr package.

Data is visualized with ggplot2, layered using ggnewscale, styled with a viridis color palette, and annotated with scale bars and north arrows.

The final map is saved as bd_pop_hillshade.png.

📦 Output Preview

> Caption: Bangladesh • Population (2020), with hillshade overlay. > Data: WorldPop & SRTM (via elevatr) > Design: SumonCODE-hash

🙌 Acknowledgments
Data sources: WorldPop, SRTM via elevatr

Inspired by cartographic workflows and R spatial analysis tutorials
