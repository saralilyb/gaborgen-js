# Gabor patch generator

CoffeeScript/JavaScript Gabor patch generator. The function takes values for rotation and frequency between 1 and 100 and outputs an image URL for a Gabor patch with rotation values between 0 and 90 degrees and frequency between .01 and .1. Makes *heavy* use of [numeric.js](http://numeric.js). You can remove the final call to `numeric.imageURL` (and/or the final call to `rescale`) to get the matrix itself. This code is *very* fast given, well, JavaScript. On my machine the math takes about 250ms, while MATLAB's routines take about 115ms.

## The main generating function

The core of this function is a construction based on the OCTAVE/MATLAB code from Wikipedia.

Start with a function definition. This takes takes values for rotation and frequency from 0 to 100, scaling them within the ranges defined below.

	gaborgen = (tilt, sf) ->

Check inputs to make sure they're between 1 and 100, a standardized range.

		console.log "ERROR: gaborgen arguenment input out of bounds" if (tilt > 100 or tilt < 1) or (sf > 100 or sf < 1)

Constants:

		reso = 400 # should be 400, lowered for testing
		phase = 0
		sc = 50.0
		contrast = 100.0
		aspectratio = 1.0
		#tilt = 45 # ranges from 0 to 90
		#sf = .07 # ranges from .01 to .1
		tilt_min = 0 # degrees
		tilt_max = 90
		sf_min = .01
		sf_max = .1

Now we want to rescale the inputs to the values needed in the equation. These functions are defined below.

		tilt = rescale_core(tilt, tilt_min, tilt_max, 1, 100)
		sf = rescale_core(sf, sf_min, sf_max, 1, 100)

More calculations.

		x = reso / 2
		y = reso / 2
		a = numeric.cos([deg2rad(tilt)]) * sf * 360
		b = numeric.sin([deg2rad(tilt)]) * sf * 360
		multConst = 1 / (numeric.sqrt([2 * pi]) * sc)
		varScale = 2 * numeric.pow([sc], 2)
		gridArray = numeric.linspace(0, reso) #
		[gab_x, gab_y] = meshgrid(gridArray)
		x_centered = numeric.sub(gab_x, x)
		y_centered = numeric.sub(gab_y, y)
		x_factor = numeric.mul(numeric.pow(x_centered, 2), -1)
		y_factor = numeric.mul(numeric.pow(y_centered, 2), -1)
		preSinWave = numeric.add(numeric.add(numeric.mul(a, x_centered), numeric.mul(b, y_centered)), phase)

I'm not sure how to `map` in numeric.js. This just converts degrees to radians throughout the matrix.

		i = 0
		while i < reso
			j = 0
			while j < reso
				preSinWave[i][j] = deg2rad(preSinWave[i][j])
				j+=1
			i+=1

There. Now, let's continue.

		sinWave = numeric.sin(preSinWave)
		m = numeric.add(.5, numeric.mul(contrast, numeric.transpose(numeric.mul(numeric.mul(multConst, numeric.exp(numeric.add(numeric.div(x_factor, varScale), numeric.div(y_factor, varScale)))), sinWave))))

Now we have a matrix of values. Matlab has the wonderful and magical `imshow` command that just takes the matrix and makes a picture. We have to do that magic ourselves. So to use the matrix `m` in the pnglib code below, we have to rescale all the values to be between 0 and 255, the intensity values for each pixel. Finally, we rescale the image matrix to be between 0 and 255.

		scaledM = rescale(m, 0, 254)

# Display the picture.

Finally, write it out. Numeric has a function that returns the base64 version of a PNG. It's kinda malformed because MATLAB doesn't want to import it, and it's slightly different from PNGlib's, but it's twice as fast. Putting the image into the DOM is handled in the HTML to make this function more general purpose.

		return numeric.imageURL([scaledM,scaledM,scaledM])

## Helper functions

Start with some helper functions. This function converts degrees to radians.

	pi = 3.1416 # matlab's value
	deg2rad = (degrees) ->
		(degrees * pi) / 180

The following are done up to dig into nested arrays and find the max or min values in them. These return *very* efficient functions.

	arrmax = numeric.mapreduce('if(xi > accum) accum=xi;','-Infinity');
	arrmin = numeric.mapreduce('if(xi < accum) accum=xi;','Infinity');

`meshgrid` takes an array then replicates it `l` times and returns a matrix, where `l` is the array's length.

	meshgrid = (value) ->
		m = []
		value_length = value.length
		i = 0
		while i < value_length
			m.push(value)
			i += 1
		[m, numeric.transpose(m)]

The rescale function is a core function we'll wrap up for clarity. This is based on [Gabriel Peyre](http://www.mathworks.com/matlabcentral/fileexchange/5103-toolbox-diffc/content/toolbox_diffc/toolbox/rescale.m)'s 2004 `rescale.m`, which uses a BSD license.

	rescale_core = (y, a, b, m, M) ->
		y if M - m < .0000001
		numeric.add(numeric.mul(b - a, numeric.div(numeric.sub(y, m), M - m)), a)
	rescale = (y, a, b) ->
		rescale_core(y, a, b, arrmin(y), arrmax(y))
