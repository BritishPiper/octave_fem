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
## @deftypefn {} {@var{K_local} =} local_matrices (@var{coordinates}, @var{topology}, @var{conductivity})
## Computes the FEM local matrices of the Generalized Poisson Equation, 
## supposing tetrahedral elements. The conductivity function receives the element id
## and returns its conductivity matrix.@*@*
## @var{coordinates} (m x 4 matrix) - Coordinates/Nodes matrix@*
## @var{topology} (n x 5 matrix) - Topology/Elements matrix@*
## @var{conductivity} (function) - Conductivity function@*
## @var{K_local} (4 x 4 x n matrix) - Local matrices@*
## @seealso{read_msh, global_matrix}
## @end deftypefn

## Author: Arthur Clemente Giannotta
## Created: 2020-11-09

function K_local = local_matrices (coordinates, topology, conductivity)
  # Setups the default results
  K_local = [];
  
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
  V = zeros(4, 4); # Volume matrix
  B = zeros(3, 4); # Cofactor matrix
  
  K_local = zeros(4, 4, length(topology));
  
  # Iterates the elements in the topology
  for row = 1:rows(topology)
    element = topology(row, 1);   # The element id
    nodes = topology(row, 2:end); # The nodes of the element
    n_nodes = length(nodes);      # The number of nodes in an element (should be 4)
    
    for i = 1:n_nodes
      # Volume matrix:
      # [1 x1 y1 z1
      #  1 x2 y2 z2
      #  ...
      #  1 xn yn zn]
      V(i, :) = [1 coordinates(nodes(i), 2:end)];
    endfor
    
    # Calculates the inverse matrix
    
    # This line works, is fast, but the inverse function is unreliable error-wise
    # B2 = inv(V)(2:end, :);
    
    # Calculates 6 * volume
    v6 = det(V);
    
    # Calculates the adjugate matrix (beta, gamma, delta coefficients)
    for i = 1:n_nodes
      for j = 2:n_nodes
        # Eliminate the i-th row and j-column
        A = V([1:i-1 i+1:n_nodes], [1:j-1 j+1:n_nodes]);
        
        # i and j are inverted since the adjugate is the transpose of the cofactor matrix
        if mod(i + j, 2) == 0
          B(j - 1, i) = det(A);
        else
          B(j - 1, i) = -det(A);
        endif
      endfor
    endfor
    
    # Gets the conductivity matrix
    D = conductivity(element);
    
    # In reality, B = B / v6, but we don't calculate it for speed and precision
    # To compensate for this, the next equation is divided by 6 * v6 instead of multiplied by v6 / 6
    
    # Computes the local matrix from v6, D and B
    K_local(:, :, row) = (B' * D * B) / (6 * v6);
  endfor
endfunction
