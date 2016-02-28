# Gabor patch generator

Uses [PNGlib](http://www.xarg.org/2010/03/generate-client-side-png-files-using-javascript/), which has a BSD license.

Temporary

	text = 'Testing!'

Example code from PNGlib to generate a png, translated by [js2.coffe](http://js2.coffee/).

	p = new PNGlib(200, 200, 256)
	# construcor takes height, weight and color-depth
	background = p.color(0, 0, 0, 0)
	# set the background transparent
	i = 0
	num = 200 / 10
	while i <= num
		x = i * 10
		y = Math.sin(i) * Math.sin(i) * 50 + 50
		# use a color triad of Microsofts million dollar color
		p.buffer[p.index(Math.floor(x), Math.floor(y - 10))] = p.color(0x00, 0x44, 0xcc)
		p.buffer[p.index(Math.floor(x), Math.floor(y))] = p.color(0xcc, 0x00, 0x44)
		p.buffer[p.index(Math.floor(x), Math.floor(y + 10))] = p.color(0x00, 0xcc, 0x44)
		i += .01
	i = 0
	while i < 50
		j = 0
		while j < 50
			p.buffer[p.index(i + 90, j + 135)] = p.color(0xcc, 0x00, 0x44)
			p.buffer[p.index(i + 80, j + 120)] = p.color(0x00, 0x44, 0xcc)
			p.buffer[p.index(i + 100, j + 130)] = p.color(0x00, 0xcc, 0x44)
			j++
		i++
	the_image = '<img src="data:image/png;base64,' + p.getBase64() + '">'

And finally write the output to the DOM element.

	$('#gab-target').html(the_image)
