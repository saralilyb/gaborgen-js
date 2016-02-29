# Gabor patch generator

Uses [PNGlib](http://www.xarg.org/2010/03/generate-client-side-png-files-using-javascript/), which has a BSD license.

Constants

	pi = 3.1416 # matlab's value
	reso = 400 # should be 400, lowered for testing
	phase = 0
	sc = 50.0
	contrast = 100.0
	aspectratio = 1.0
	tilt = 45 # ranges from 0 to 90
	sf = .07 # ranges from .01 to .1

Now math. This function converts degrees to radians.

	deg2rad = (degrees) ->
		(degrees * pi) / 180

The following are done up to dig into nested arrays. From [StackOverflow](http://stackoverflow.com/questions/10564441/how-to-find-the-max-min-of-a-nested-array-in-javascript).

	arrmax = (arrs) ->
		toplevel = []
		f = (v) ->
			!isNaN(v)
		i = 0
		l = arrs.length
		while i < l
			toplevel.push Math.max.apply(window, arrs[i].filter(f))
			i++
		Math.max.apply window, toplevel
	arrmin = (arrs) ->
		toplevel = []
		f = (v) ->
			!isNaN(v)
		i = 0
		l = arrs.length
		while i < l
			toplevel.push Math.min.apply(window, arrs[i].filter(f))
			i++
		Math.min.apply window, toplevel


`meshgrid` takes an array then replicates it `l` times and returns a matrix, where `l` is the array's length.

	meshgrid = (value) ->
		m = []
		value_length = value.length
		i = 0
		while i < value_length
			m.push(value)
			i += 1
		[m, numeric.transpose(m)]

Lay groundwork. Right now this assumes square gabor patches. This makes heavy use of [numeric.js](http://numeric.js). This is a construction based on the OCTAVE/MATLAB code from Wikipedia.

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
	# sinWave = math.sin math.map(preSinWave, (value) ->
	# 	math.unit(value, 'deg').value)

I'm not sure how to `map` in numeric.js.

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

Now we have a matrix of values. Matlab has the wonderful and magical `imshow` command that just takes the matrix and makes a picture. We have to do that magic ourselves. So to use the matrix `m` in the pnglib code below, we have to rescale all the values to be between 0 and 255, the intensity values for each pixel. The first function is a core function we'll wrap up later for clarity. This is based on [Gabriel Peyre](http://www.mathworks.com/matlabcentral/fileexchange/5103-toolbox-diffc/content/toolbox_diffc/toolbox/rescale.m)'s 2004 `rescale.m`, which uses a BSD license.

	rescale_core = (y, a, b, m, M) ->
		y if M - m < .0000001
		numeric.add(numeric.mul(b - a, numeric.div(numeric.sub(y, m), M - m)), a)

	rescale = (y, a, b) ->
		rescale_core(y, a, b, arrmin(y), arrmax(y))

Finally, we rescale the image matrix to be between 0 and 255.

	scaledM = rescale(m, 0, 255)
	scaledM = numeric.transpose(scaledM)

# Display the picture.

Now we create a PNG element and loop through it, changing each pixel's color.

	p = new PNGlib(reso, reso, 256)
	# construcor takes height, weight and color-depth
	background = p.color(0, 0, 0, 0)
	# set the background transparent
	i = 0
	while i < reso
		j = 0
		while j < reso
			grayval = scaledM[i][j]
			p.buffer[p.index(i, j)] = p.color(grayval, grayval, grayval)
			#p.buffer[p.index(i + 90, j + 135)] = p.color(0xcc, 0xcc, 0xcc)
			#p.buffer[p.index(i + 80, j + 120)] = p.color(0x44, 0x44, 0x44)
			#p.buffer[p.index(i + 100, j + 130)] = p.color(0x00, 0x00, 0x00)
			j++
		i++
	the_image = '<img src="data:image/png;base64,' + p.getBase64() + '">'

And finally write the output to the DOM element.

	$('#gab-target').html(the_image)
