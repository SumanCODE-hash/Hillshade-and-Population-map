# install packages and load
library(tidyverse)
library(raster)
library(sf)
library(ggplot2)
library(RColorBrewer)
library(sf)
library(st)
library(ggspatial)
library(terra)
library(geodata)
library(ggnewscale)
library(elevatr)
library(scales)

# Download the BGD boundary

bd_sf <- geodata::gadm(country = "BGD", level = 0, path = tempdir()) |>
sf::st_as_sf()
# Converting to it in vector format
bd_vect <- terra::vect(bd_sf)



# Load directly the POPULATION 100M bd link to load as geodata
bd_pop_100m <-  terra::rast("https://data.worldpop.org/GIS/Population/Global_2000_2020_Constrained/2020/BSGM/BGD/bgd_ppp_2020_constrained.tif")

# Plot the population data
terra::plot(bd_pop_100m)


# Get Dem and Hillshade data
bd_dem <- elevatr::get_elev_raster(bd_sf, z = 10, clip = "locations")

# Turn the DEM into a raster and corp and mask it to the BGD boundary (to avoid NA values)
bd_dem_raster <- terra::rast(bd_dem) |>
    terra::crop(bd_vect) |>
    terra::mask(bd_vect)


# Shaded relief
bd_slope <- terra::terrain(bd_dem_raster, v = "slope", unit = "radians")

aspect <- terra::terrain(bd_dem_raster, v = "aspect", unit = "radians")

# Create hillshade raw
hillshade_raw <- terra::shade(bd_slope, aspect, angle = 30, direction = 215) #Change the angle and direction to get different hillshades

#  Resample the hillshade to match the population raster resolution/ grid
hillshade_on_pop <- terra::resample(bd_pop_100m, hillshade_raw, method = "bilinear")

# Map the hillshade only where the population data is not available
hillshade_no_pop <- terra::ifel(is.na(hillshade_on_pop),hillshade_raw, NA)



# Convert the hillshade raster file and population to a data frame for ggplot
hillshade_df <- terra::as.data.frame(
    hillshade_no_pop, na.rm = TRUE,
    xy = TRUE)

# See the first few rows of the hillshade data frame
head(hillshade_df)

# Save the hillshade data frame as a CSV file for further use
write.csv(hillshade_df, "hillshade_df.csv", row.names = FALSE)

# Convert the population raster file to a data frame for ggplot
pop_df <- terra::as.data.frame(
    hillshade_on_pop, na.rm = TRUE,   # bd_pop_100m or hillshade_no_pop 
    xy = TRUE)

# See the first few rows of the population data frame
head(pop_df)

#See the summary of the population data frame
summary(pop_df$bgd_ppp_2020_constrained)

# Cut off the pop_df$bgd_ppp_2020_constrained to 0.1 to max
pop_df <- pop_df$bgd_ppp_2020_constrained[pop_df$bgd_ppp_2020_constrained <= 0.1] <- NA


# ## legend breaks once, so we can reuse them
brks <- c(3.4, 10, 100, 1000, 10000, 25249.348)




## create a ggplot with the hillshade and population data
# a) hill-shadeAdd commentMore actions
p <- ggplot() +
    geom_raster(data = hillshade_df, aes(
        x, y,
        fill = bgd_ppp_2020_constrained
    )) +
    scale_fill_gradient(
        low = "grey70", high = "grey10",
        guide = "none"
    ) +
    # 2) population layer
    ggnewscale::new_scale_fill() +
    geom_raster(data = pop_df, aes(
        x, y,
        fill = bgd_ppp_2020_constrained
    )) +
    scale_fill_viridis_c(
        name = "Population",
        option = "plasma",
        alpha = 1, begin = .2, end = 1,
        trans = "log10", breaks = brks,
        labels = scales::comma,
        guide = guide_colourbar(
            title.position = "top",
            barheight = unit(30, "mm"),
            barwidth = unit(2, "mm"),
            ticks.color = "grey10",
            frame.colour = "grey10"
        )
    ) +
    # 3) country boundaries
    geom_sf(
        data = bd_sf, fill = NA,
        color = "black", linewidth = .25
    ) +
    # 4) cartographic extras
    ggspatial::annotation_north_arrow(
        location = "tl", which_north = "true",
        height = unit(10, "mm"),
        width = unit(10, "mm"),
        style = ggspatial::north_arrow_fancy_orienteering()
    ) +
    ggspatial::annotation_scale(
        location = "br", pad_y = unit(2, "mm"),
        height = unit(2, "mm")
    ) +
    coord_sf(expand = FALSE) +
    # 5) typography & layout
    labs(
        title = "Bangladesh · Population (2020)",
        subtitle = "WorldPop 100m constrained grid",
        caption = "Data: WorldPop · SRTM via elevatr | Design: SumonCODE-hash"
    ) +
    theme(
        plot.title = element_text(
            size = 16, face = "bold", hjust = .02
        ),
        plot.subtitle = element_text(
            size = 14, hjust = .02
        ),
        plot.caption = element_text(
            hjust = .5
        ),
        legend.title = element_text(
            size = 12
        ),
        legend.text = element_text(
            size = 11
        ),
        legend.margin = margin(
            t = 0, r = 5, b = 0, l = 3
        ),
        plot.margin = margin(
            t = 5, r = 5, b = 5, l = 5
        )
    ) +
    theme_void()

# See the plot
print(p)


# Save the plot as a PNG file
ggsave(
    "bd_pop_hillshade.png",
    plot = p,
    width = 8, height = 10, dpi = 600,
    units = "in", bg = "white"
)