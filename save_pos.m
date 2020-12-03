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
## @deftypefn {} {@var{num_bytes} =} save_pos (@var{filename}, @var{coordinates}, @var{topology}, @var{solution})
## Saves the solution of the finite elements method into a .pos file.@*@*
## @var{filename} (string) - Path to the .pos file@*
## @var{coordinates} (m x 4 matrix) - Coordinates/Nodes matrix@*
## @var{topology} (n x 5 matrix) - Topology/Elements matrix@*
## @var{solution} (m x 1 vector) - Solution vector@*
## @var{num_bytes} (integer) - Total number of bytes written to the file@*
## @seealso{global_matrix, set_boundary}
## @end deftypefn

## Author: Arthur Clemente Giannotta
## Created: 2020-09-25

function num_bytes = save_pos (filename, coordinates, topology, solution)
  # Auxiliary functions to avoid duplicate code
  function fprintf_node(xyz)
    num_bytes += fprintf(file, "%g,%g,%g", xyz(2), xyz(3), xyz(4));
  endfunction
  
  # Setups the default result
  num_bytes = 0;
  
  # Type checking for all the input parameters
  if !ischar(filename) || length(filename) < 1
    printf("Invalid filename for function \"save_pos\": Should be a nonempty string\n");
    return;
  elseif !ismatrix(coordinates) || size(coordinates)(1) < 1 || size(coordinates)(2) != 4
    printf("Invalid coordinates matrix for function \"save_pos\": Should be a nonempty matrix with 4 columns\n");
    return;
  elseif !ismatrix(topology) || size(topology)(1) < 1 || size(topology)(2) != 5
    printf("Invalid topology matrix for function \"save_pos\": Should be a nonempty matrix with 5 columns\n");
    return;
  elseif !ismatrix(solution) || length(solution) != size(coordinates)(1) || (size(solution)(1) != 1 && size(solution)(2) != 1)
    printf("Invalid solution vector for function \"save_pos\": Should be a vector with solutions for each node coordinate\n");
    return;
  endif
  
  # Creates a file with write access
  # The try-catch block is here to ensure the file is created successfully
  try
    file = fopen(filename, "w");
    
    assert(file != -1);
  catch err
    # Shows an error message if the file failed to be created
    printf("\"save_pos\": Failed to create a file with name %s\n", filename);
    return;
  end_try_catch
  
  # The try-catch block is here to ensure the file is closed if an error occurs
  try
    # Every .pos image file starts with this line
    num_bytes += fprintf(file, "View \"image\" {\n");
    
    # Iterates the topology matrix
    for row = 1:rows(topology)
      element = topology(row, :);
      
      # Starts printing the node coordinates
      num_bytes += fprintf(file, "SS(");
      
      # Prints the first node coordinate
      first_node = element(2);
      fprintf_node(coordinates(first_node, :))
      
      # Prints the coordinates for the remaining nodes
      for node = element(3:end)
        num_bytes += fprintf(file, ",");
        fprintf_node(coordinates(node, :))
      endfor
      
      # Ends printing the node coordinates
      # Starts printing the solution for each node
      num_bytes += fprintf(file, "){%g", solution(first_node));
      
      # Prints solution for the remaining nodes
      for node = element(3:end)
        num_bytes += fprintf(file, ",%g", solution(node));
      endfor
      
      # Ends printing the solution for each node
      num_bytes += fprintf(file, "};\n");
    endfor
    
    # Every .pos image file ends with this line
    num_bytes += fprintf(file, "};");
  catch err
    # Shows a generic error message if something bad happened
    warning(err.message, err.identifier);
    printf("\"save_pos\": There may be missing data in %s\n", filename);
    return;
  end_try_catch
  
  # Closes the file handle
  fclose(file);
endfunction
