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
## Created: 2020-11-08

# Generalized Poisson Equation (LaTEX)
# $\Delta \cdot (\epsilon\ \Delta V) = -\frac{\rho}{\epsilon_0}}$

clc; clear all;
format long g;

# Times the execution of the script
global_start = tic;

# 0) Sets the mesh, dirichlet, neumann and output file names
mesh      = "Meshes/mesh.msh";
dirichlet = "Meshes/Dirichlet.dat";
neumann   = "Meshes/Neumann.dat";
output    = "Output/output.pos";
results   = "Output/results.txt";

# 0b) Sets the conductivity function
function k = conductivity(element)
  #k_object = 0.01 * eye(3); # (Ohm.m)^-1
  #k_domain = 1.00 * eye(3); # (Ohm.m)^-1
  
  #if element <= 1536 # Inside of the object
  #  k = k_object;
  #else # Inside of the domain, outside of the object
  #  k = k_domain;
  #endif
  
  k = 0.25 * eye(3); # (Ohm.m)^-1
endfunction

start = tic;

# 1a) Reads the mesh file
[coordinates, topology, version] = read_msh(mesh);

# 1b) Tries to read the boundary conditions
try
  neumann = load(neumann);
  dirichlet = load(dirichlet);
catch err
  warning(err.message, err.identifier);
  printf("\nFailed to read the boundary conditions\n", filename);
end_try_catch

printf("\nMesh and Boundary Conditions read in %f seconds\n", toc(start)); start = tic;

# 2) Computes the local matrices

# Parallel computation (faster, but requires pkg parallel)
# global K_local;
# par_local_matrices(coordinates, topology, @conductivity);

#printf("\nLocal matrices computed with parallelism in %f seconds\n", toc(start)); start = tic;

# Serial computation
K_local = local_matrices(coordinates, topology, @conductivity);

printf("\nLocal matrices computed in %f seconds\n", toc(start)); start = tic;

# 3) Assembles the global matrix
K_global = global_matrix(topology, K_local);

printf("\nGlobal matrix assembled in %f seconds\n", toc(start)); start = tic;

# 4) Imposes the Dirichlet and Neumann boundary conditions
set_boundary;

printf("\nBoundary conditions imposed in %f seconds\n", toc(start)); start = tic;

# 5) Solves the linear system
solution = K_global \ b;

printf("\nLinear system solved in %f seconds\n", toc(start)); start = tic;

# 6a) Outputs the solution into a .pos file
num_bytes = save_pos(output, coordinates, topology, solution);
printf("\nSucessfully written %d bytes of data into %s\n", num_bytes, output);

# 6b) Prints the results in the command window
# printf("\n"); show_results(coordinates, topology, solution);

# 6c) Tries to save the results for each element into a text file
try
  file = fopen(results, "w");
  show_results(coordinates, topology, solution, file);
  fclose(file);
catch err
  warning(err.message, err.identifier);
  printf("\nFailed to save the results\n", filename);
end_try_catch

printf("\nScript executed in %f seconds\n", toc(global_start));
