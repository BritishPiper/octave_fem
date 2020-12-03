## Copyright (C) 2020 Arthur Clemente Giannotta
## 
## This program is free software: you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see
## <https://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## This is the main program file, which calls all of the required routines
## to calculate the finite element solution.

## Author: Arthur Clemente Giannotta
## Created: 2020-12-01

clc; clear all;
format long g;

# Times the execution of the script
global_start = tic;

# 0) Sets the mesh file name and the matrix of points we're trying to approximate
mesh = "Meshes/mesh.msh";

points = [
  +0.15, 0, 0;
  -0.15, 0, 0;
  0, +0.15, 0;
  0, -0.15, 0;
  0, 0, +0.15;
  0, 0, -0.15;
];

# Function that calculates the distance between two points (can be customized)
function d = distance(a, b)
  d = sum((a - b).^2);
endfunction

start = tic;

# 1) Reads the mesh file
[coordinates, topology, version] = read_msh(mesh);

printf("\nMesh read in %f seconds\n", toc(start)); start = tic;

start = tic;

# 2) Iterates the nodes to find the closest coordinates to the points being approximated

approximated = zeros(size(points) + [0, 2]);
approximated(:, 2) = inf; # Starting minimum distance must be infinity

for i = 1:rows(coordinates)
  node  = coordinates(i, 1);
  coord = coordinates(i, 2:end);

  for j = 1:rows(points)
    point = points(j, :);
    dist = distance(point, coord);

    if dist < approximated(j, 2)
      approximated(j, 1) = node;
      approximated(j, 2) = dist;
      approximated(j, 3:end) = coord;
    endif
  endfor
endfor

printf("\nApproximated points found in %f seconds\n", toc(start));

# 3) Prints the results for each approximated point

printf("\n Node | Coordinates | Approximated Point | Distance\n")
for j = 1:rows(approximated)
  point = points(j, :);
  node  = approximated(j, 1);
  err   = approximated(j, 2);
  coord = approximated(j, 3:end);

  printf("%6d | %+.5f, %+.5f, %+.5f | %+.5f, %+.5f, %+.5f | %f\n", node,
    coord(1), coord(2), coord(3),
	point(1), point(2), point(3),
	err);
endfor

printf("\nScript executed in %f seconds\n", toc(global_start));
