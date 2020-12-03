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
## @deftypefn {} showresults (@var{coordinates}, @var{topology}, @var{solution}[, @var{file}])
## Prints the solution of the finite elements method into the command window@*@*
## @var{coordinates} (m x 4 matrix) - Coordinates/Nodes matrix@*
## @var{topology} (n x 5 matrix) - Topology/Elements matrix@*
## @var{solution} (m x 1 vector) - Solution vector@*
## @var{file} (scalar) - Output file descriptor (defaults to stdout)@*
## @seealso{solve}
## @end deftypefn

## Author: Arthur Clemente Giannotta
## Created: 2020-09-25

function show_results (coordinates, topology, solution, file = stdout)
  # Type checking for all the input parameters
  if !isscalar(file) || file == -1
    printf("Invalid file descriptor for function \"show_results\": Should be a nonnegative integer\n");
    return;
  elseif !ismatrix(coordinates) || size(coordinates)(1) < 1 || size(coordinates)(2) != 4
    printf("Invalid coordinates matrix for function \"show_results\": Should be a nonempty matrix with 4 columns\n");
    return;
  elseif !ismatrix(topology) || size(topology)(1) < 1 || size(topology)(2) != 5
    printf("Invalid topology matrix for function \"show_results\": Should be a nonempty matrix with 5 columns\n");
    return;
  elseif !ismatrix(solution) || length(solution) != size(coordinates)(1) || (size(solution)(1) != 1 && size(solution)(2) != 1)
    printf("Invalid solution vector for function \"show_results\": Should be a vector with solutions for each node coordinate\n");
    return;
  endif
  
  # For each element
  for row = 1:rows(topology)
    element = topology(row, :);
    
    # Prints the first node separately (because of comma issues)
    fprintf(file, "Element %d - Nodes { %d", row, element(2));
    sum = solution(element(2));
    
    # Prints the rest of the nodes
    for node = element(3:end)
      fprintf(file, ", %d", node);
      sum += solution(node);
    endfor
    
    fprintf(file, " } -> %5.3f\n", 0.25 * sum); # Computes and prints the average of the nodes
  endfor
endfunction
