// Generated by CoffeeScript 1.10.0
var arrmax, arrmin, deg2rad, gaborgen, meshgrid, pi, rescale, rescale_core;

gaborgen = function(tilt, sf) {
  var a, aspectratio, b, background, contrast, gab_x, gab_y, grayval, gridArray, i, j, m, multConst, p, phase, preSinWave, ref, reso, sc, scaledM, sinWave, varScale, x, x_centered, x_factor, y, y_centered, y_factor;
  reso = 400;
  phase = 0;
  sc = 50.0;
  contrast = 100.0;
  aspectratio = 1.0;
  x = reso / 2;
  y = reso / 2;
  a = numeric.cos([deg2rad(tilt)]) * sf * 360;
  b = numeric.sin([deg2rad(tilt)]) * sf * 360;
  multConst = 1 / (numeric.sqrt([2 * pi]) * sc);
  varScale = 2 * numeric.pow([sc], 2);
  gridArray = numeric.linspace(0, reso);
  ref = meshgrid(gridArray), gab_x = ref[0], gab_y = ref[1];
  x_centered = numeric.sub(gab_x, x);
  y_centered = numeric.sub(gab_y, y);
  x_factor = numeric.mul(numeric.pow(x_centered, 2), -1);
  y_factor = numeric.mul(numeric.pow(y_centered, 2), -1);
  preSinWave = numeric.add(numeric.add(numeric.mul(a, x_centered), numeric.mul(b, y_centered)), phase);
  i = 0;
  while (i < reso) {
    j = 0;
    while (j < reso) {
      preSinWave[i][j] = deg2rad(preSinWave[i][j]);
      j += 1;
    }
    i += 1;
  }
  sinWave = numeric.sin(preSinWave);
  m = numeric.add(.5, numeric.mul(contrast, numeric.transpose(numeric.mul(numeric.mul(multConst, numeric.exp(numeric.add(numeric.div(x_factor, varScale), numeric.div(y_factor, varScale)))), sinWave))));
  scaledM = rescale(m, 0, 255);
  scaledM = numeric.transpose(scaledM);
  p = new PNGlib(reso, reso, 256);
  background = p.color(0, 0, 0, 0);
  i = 0;
  while (i < reso) {
    j = 0;
    while (j < reso) {
      grayval = scaledM[i][j];
      p.buffer[p.index(i, j)] = p.color(grayval, grayval, grayval);
      j++;
    }
    i++;
  }
  return $('#gab-target').html('<img src="data:image/png;base64,' + p.getBase64() + '">');
};

pi = 3.1416;

deg2rad = function(degrees) {
  return (degrees * pi) / 180;
};

arrmax = function(arrs) {
  var f, i, l, toplevel;
  toplevel = [];
  f = function(v) {
    return !isNaN(v);
  };
  i = 0;
  l = arrs.length;
  while (i < l) {
    toplevel.push(Math.max.apply(window, arrs[i].filter(f)));
    i++;
  }
  return Math.max.apply(window, toplevel);
};

arrmin = function(arrs) {
  var f, i, l, toplevel;
  toplevel = [];
  f = function(v) {
    return !isNaN(v);
  };
  i = 0;
  l = arrs.length;
  while (i < l) {
    toplevel.push(Math.min.apply(window, arrs[i].filter(f)));
    i++;
  }
  return Math.min.apply(window, toplevel);
};

meshgrid = function(value) {
  var i, m, value_length;
  m = [];
  value_length = value.length;
  i = 0;
  while (i < value_length) {
    m.push(value);
    i += 1;
  }
  return [m, numeric.transpose(m)];
};

rescale_core = function(y, a, b, m, M) {
  if (M - m < .0000001) {
    y;
  }
  return numeric.add(numeric.mul(b - a, numeric.div(numeric.sub(y, m), M - m)), a);
};

rescale = function(y, a, b) {
  return rescale_core(y, a, b, arrmin(y), arrmax(y));
};
