# gaborgen

If you're doing a behavioral experiment online with Gabor patches, participants have to see a lot of them. That means they have to download a lot of images. Instead of that, why not generate the images on the client side? That's what this function does. [See it live here.](http://jtth.github.io/gaborgen-js/)

CoffeeScript/JavaScript Gabor patch generator. The fucntion takes values for rotation and frequency between 1 and 100 and outputs a Gabor patch with rotation values between 0 and 90 degrees and frequency between .01 and .1. Makes *heavy* use of [numeric.js](http://numeric.js). There is also a version written in MathJS, but that version takes about six seconds whereas the numeric.js version takes 500ms. Then it rescales the matrix values to be between 0 and 255, and outputs those to an image on the demo web page.

There's also a web page with two sliders that show how fast the generation is by updating the parameters of the Gabor patch with each value change.
