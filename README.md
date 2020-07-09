# MATLAB look up table objects

by

Mark Cary

Basic version which implements correct interpolation behaviour without extrapolation.
These objects are designed to be composited in parent objects to permit
evaluation of the look up tables at the conditions indicated.

lookUp      --> Abstract interface
fcnLookUp   --> 1-dimensional look up table
tableLookUp --> 2-dimensional look up table

%%%%% TO DO %%%%%
Implement regularised fitting and optimal breakpoint location via shared average curvature. 