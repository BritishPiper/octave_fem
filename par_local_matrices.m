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
## @deftypefn {} {@var{K_local} =} par_local_matrices (@var{coordinates}, @var{topology}, @var{conductivity}, @var{n_threads})
## Computes the FEM local matrices of the Generalized Poisson Equation, 
## supposing tetrahedral elements. The conductivity function receives the element id
## and returns its conductivity matrix. This function uses parallelism to be faster.
## The result is stored in the global variable K_local.@*@*
## @var{coordinates} (m x 4 matrix) - Coordinates/Nodes matrix@*
## @var{topology} (n x 5 matrix) - Topology/Elements matrix@*
## @var{conductivity} (function) - Conductivity function@*
## @var{K_local} (4 x 4 x n matrix) - Local matrices@*
## @var{n_threads} (scalar) - Number of parallel threads@*
## @seealso{read_msh, global_matrix}
## @end deftypefn

## Author: Arthur Clemente Giannotta
## Created: 2020-11-09

function par_local_matrices (coordinates, topology, conductivity, n_threads = 4)  
  # Type checking for all the input parameters
  if !ismatrix(coordinates) || size(coordinates)(1) < 1 || size(coordinates)(2) != 4
    printf("Invalid coordinates matrix for function \"local_matrices\": Should be a nonempty matrix with 4 columns\n");
    return;
  elseif !ismatrix(topology) || size(topology)(1) < 1 || size(topology)(2) != 5
    printf("Invalid topology matrix for function \"local_matrices\": Should be a nonempty matrix with 5 columns\n");
    return;
  elseif !is_function_handle(conductivity)
    printf("Invalid conductivity for function \"local_matrices\": Should be a function handle\n");
    return;
  endif
  
  # Pre-allocates memory
  global K_local = zeros(4, 4, length(topology));
  
  V = cell(length(topology), 1); # Volume matrices
  K = cell(length(topology), 1); # Conductivities
  
  # Tries to setup parallel computing
  try
    pkg load parallel;
  catch err
    printf("\nFailed to load parallel package\nCode execution will be slower\nDid you run \"pkg install -forge parallel\" and \"pkg install -forge struct\"?\n");
    return;
  end_try_catch
  
  # Iterates the elements in the topology
  for row = 1:rows(topology)
    element = topology(row, 1);   # The element id
    nodes = topology(row, 2:end); # The nodes of the element
    
    V{row} = zeros(4, 4);
    
    for i = 1:4
      # Volume matrix:
      # [1 x1 y1 z1
      #  1 x2 y2 z2
      #  ...
      #  1 xn yn zn]
      V{row}(i, :) = [1 coordinates(nodes(i), 2:end)];
    endfor
    
    # Gets the conductivity matrix
    K{row} = conductivity(element);
  endfor
  
  # The result of the parallel operation is stored in a global variable K_local
  parcellfun(n_threads, @par_local_matrix, num2cell(1:length(topology))', V, K, "CumFunc", @par_cumulate_local);
endfunction
