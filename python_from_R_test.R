# run python from R based on:
# https://www.r-bloggers.com/run-python-from-r/

library(assertthat)
library(reticulate) # cool!

# check whether python's available
assertthat::assert_that(py_available(initialize = TRUE))

# path to picture
path <- "/home/richard/Dropbox/PROMOTION WORKING FOLDER/General/Functions/Python_from_R"
picture_path <- file.path(path, "test_pic.jpg")

# simulate some fixations
x_positions <- rnorm(100, mean = 300, sd = 100)
y_positions <- rnorm(100, mean = 150, sd = 40)


##### here goes python #####
print("Entering python...")
repl_python()
# load python libraries
from pylab import *
from scipy import stats, c_, reshape, rot90
# read picture in python
picture = imread(r.picture_path)
clf() # clear any figure
picplot = imshow(picture)
lims = plt.axis()   # get image plot size from axes IMPORTANT
pic_width = lims[1]
pic_height = lims[2]
axis([0,pic_width, 0, pic_height])
# make kernel density estimation
X1, Y1 = mgrid[0:pic_width:100j, 0:pic_height:100j]
positions = c_[X1.ravel(), Y1.ravel()]
values = c_[r.x_positions, r.y_positions]
kernel = stats.kde.gaussian_kde(values.T)
# prediction and normalization
kde = kernel(positions.T).T
kde = (kde/sum(kde))
Z = reshape(kde, X1.T.shape)	 
# maximum density?
max_dens = max(kde)
# plot der "heatmap", hier ist die max_dens der hoechste wert auf der skala
layer = imshow(rot90(Z), vmin=0, vmax=max_dens,
               extent=[0, pic_width, 0, pic_height], cmap=cm.gist_earth_r, alpha=.5)
colorbar() #ticks=[] falls keine legende an die colorbar soll
# plot points as fixations
plot(r.x_positions, r.y_positions, 'k.', 
     markersize=1, alpha=.5, label='fixation')
# add legend and then rescale plot
legend( bbox_to_anchor=(0., 1.02, 1., .102), loc=2, ncol=2, mode="expand", borderaxespad=0., numpoints=1)
axis([0,pic_width, 0, pic_height])
plt.gca().invert_yaxis() # invert y axis, if (0/0) is in the upper left
# save the figure
savefig(r.path + "/test_pic_in_python.png")
# return to R
exit

##### end of python here #####
print("Exited from python.")

