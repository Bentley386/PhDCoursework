Homework 6 - Given a triangulation and function data, construct a spline over the triangulation interpolating it, check the interpolation error, plot its contours, check its smoothness, check error under triangulation refinement.


bpolyval.m, coeffSmoothness.m, decasteljau.m and interpolation.m are from previous HWs

changeBasis.m - calc coefficients for different barycentric frame
checkSmoothnessSpline - check smoothness of the spline
checkSmoothnesSplineOlD - same as before but not from the big spline but by building the smaller splines again from scratch
constructSpline - construct spline from data
constructSplineFromFunc - construct spline from function
doubleTriangulation - refine the triangulation by splitting each triangle into 4.
evaluateSpline - get the value for a given (x,y) point
getLinfError - get the max error for the spline

