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
## @deftypefn {} {@var{K_global} =} global_matrix (@var{topology}, @var{K_local})
## Assembles the FEM global matrix from the local matrices.@*@*
## @var{topology} (n x 5 matrix) - Topology/Elements matrix@*
## @var{K_local} (4 x 4 x n matrix) - Local matrices@*
## @var{K_global} (n x n matrix) - FEM global matrix@*
## @seealso{local_matrices, set_boundary}
## @end deftypefn

## Author: Arthur Clemente Giannotta
## Created: 2020-11-09

function K_global = global_matrix (topology, K_local)
  # Setups the default result
  K_global = [];
  
  # Type checking for all the input parameters
  if !ismatrix(topology) || size(topology)(1) < 1 || size(topology)(2) != 5
    printf("Invalid topology matrix for function \"global_matrix\": Should be a nonempty matrix with 5 columns\n");
    return;
  elseif !strcmp(typeinfo(K_local), "matrix") || length(size(K_local)) != 3 || size(K_local)(3) < 1 || size(K_local)(1) != 4 || size(K_local)(2) != 4
    printf("Invalid local matrices for function \"global_matrix\": Should be a nonempty array of matrices with 4 rows and 4 columns\n");
    return;
  endif
  
  # Pre-allocates memory
  K_global = zeros(max(max(topology(:,2:end))));
  
  # Iterate all elements
  for row = 1:rows(topology)
    nodes = topology(row, 2:end); # The nodes that compose the element
    local = K_local(:, :, row);   # The element local matrix
    
    for i = 1:length(nodes)
      node_i = nodes(i); # This node identifies the equation in the global matrix
      
      for j = 1:length(nodes)
        node_j = nodes(j); # This node specificates what node is contributing to the i-th equation
        
        # Sums the local component into the global matrix
        K_global(node_i, node_j) += local(i, j);
      endfor
    endfor
  endfor
endfunction