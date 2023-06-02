library(sf)
library(tidyverse)
library(stars)
library(raster)
library(MetBrewer)
library(colorspace)
library(rayshader)
library(rayrender)
devtools::install_github("tylermorganwall/rayrender")
1

data <- st_read("C:/Users/nymos/stephenstirling.github.io/_posts/projects/Ukraine_pop/kontur_population_UA_20220630.gpkg")

# define aspect ratio

ukr<-getData('GADM', country='UKR', level=0) |>
  st_as_sf() |>
  st_transform(crs = st_crs(data))


ukr |>
  ggplot() +
  geom_sf()

st_ukr <- st_intersection(data, ukr)


bb <- st_bbox(data)

bottom_left <- st_point(c(bb[["xmin"]], bb[["ymin"]])) |>
  st_sfc(crs = st_crs(data))

bottom_right <- st_point(c(bb[["xmax"]], bb[["ymin"]])) |>
  st_sfc(crs = st_crs(data))

data |>
  ggplot() +
  geom_sf() +
  geom_sf(data = bottom_left) +
  geom_sf(data = bottom_right, color = "red")

width <- st_distance(bottom_left, bottom_right)

top_left <- st_point(c(bb[["xmin"]], bb[["ymax"]])) |>
  st_sfc(crs = st_crs(data))

height <- st_distance(bottom_left, top_left)

if (width > height) {
  w_ratio <- 1
  h_ratio <- height / width
} else {
  h_ratio <- 1
  w_ratio <- width / height
}

# convert to raster so we can convert to matrix

size <- 4000

ukr_rast <- st_rasterize(data, 
                       nx = floor(size * w_ratio),
                       ny = floor(size * h_ratio)) 

mat <- matrix(ukr_rast$population,
              nrow = floor(size * w_ratio),
              ncol = floor(size * h_ratio))

#create color palette

c1 <- met.brewer("OKeeffe2")
swatchplot(c1)

texture <- grDevices::colorRampPalette(c1, bias = 2)(256)
swatchplot(texture)


rgl::rgl.close()

?plot_3d

mat |>
  height_shade(texture = texture) |>
  plot_3d(heightmap = mat,
          zscale = 100,
          solid = FALSE,
          shadowdepth = 0,
          shadowcolor =  "auto")

render_camera(theta = -20, phi = 45, zoom = .8)

render_highquality(
  filename = "test_plot.png",
  interactive = FALSE,
  lightdirection = 280,
  lightaltitude = c(20, 80),
  lightcolor = c(c1[2], "white"),
  lightintensity = c(600, 100)
)

?render_highquality

outfile <- "images/final_plot.png"


{
  start_time <- Sys.time()
  cat(crayon::cyan(start_time), "\n")
  if (!file.exists(outfile)) {
    png::writePNG(matrix(1), target = outfile)
  }
  render_highquality(
    filename = outfile,
    interactive = FALSE,
    lightdirection = 280,
    lightaltitude = c(20, 80),
    lightcolor = c(c1[2], "white"),
    lightintensity = c(600, 100),
    samples = 450,
    width = 600,
    height = 600
  )
  end_time <- Sys.time()
  diff <- end_time - start_time
  cat(crayon::cyan(diff), "\n")
}