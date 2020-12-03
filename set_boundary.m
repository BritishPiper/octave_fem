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
## This is a global script, meaning it modifies global variables (this is 
## done to avoid duplicating the global matrix in memory). Modifies the FEM 
## global matrix by imposing the boundary conditions and calculates the forcing 
## term b. The first column of the Dirichlet and Neumann conditions contains 
## the node identifiers and the second column contains the values of the 
## conditions.@*@*
## K_global (n x n matrix) - FEM global matrix@*
## dirichlet (p x 2 matrix) - Dirichlet boundary conditions@*
## neumann (q x 2 matrix) - Neumann boundary conditions@*
## b (n x 1 vector) - Forcing term@*
## @seealso{global_matrix}
## @end deftypefn

## Author: Arthur Clemente Giannotta
## Created: 2020-11-09

# Type checking for all the input parameters
if !ismatrix(K_global) || size(K_global)(1) < 1 || size(K_global)(1) != size(K_global)(2)
  printf("Invalid global matrix for script \"set_boundary\": Should be a nonempty square matrix\n");
elseif !ismatrix(dirichlet) || size(dirichlet)(2) != 2
  printf("Invalid Dirichlet matrix for script \"set_boundary\": Should be a matrix with 2 columns\n");
elseif !ismatrix(neumann) || size(neumann)(2) != 2
  printf("Invalid Neumann matrix for script \"set_boundary\": Should be a matrix with 2 columns\n");
else
  # Pre-allocates memory
  b = zeros(length(K_global), 1);
  
  # Iterates the Dirichlet conditions
  for i = 1:size(dirichlet)(1)
    node = dirichlet(i, 1);
    value = dirichlet(i, 2);
    
    # Updates the forcing term to reflect the fixed value of the node
    b = b - (K_global(:, node)) * value;
    
    # Zeros out the node column, since the node value is fixed by the condition
    K_global(:, node) = 0;
    
    # Replaces the corresponding node line with the identity at (node, node)
    K_global(node, :) = 0;
    K_global(node, node) = 1;
    
    # Sets the forcing term to be the exact value of the Dirichlet condition
    b(node) = value;
  endfor
  
  # Iterates the Neumann conditions
  for i = 1:size(neumann)(1)
    node = neumann(i, 1);
    
    if node > length(b)
      printf("\"set_boundary\": Invalid node %d for the neumann condition\n", node);
    else
      b(node) = neumann(i, 2);
    endif
  endfor
endif
