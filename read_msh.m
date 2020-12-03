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
## @deftypefn {} {[@var{coordinates}, @var{topology}, @var{version}] =} read_msh (@var{filename})
## Reads the information about nodes and elements inside a .msh file. Supports 
## versions 2 ASCII and 4 ASCII with tetrahedral elements.@*@*
## @var{filename} (string) - Path to the .msh file@*
## @var{coordinates} (m x 4 matrix) - Coordinates/Nodes matrix@*
## @var{topology} (n x 5 matrix) - Topology/Elements matrix@*
## @var{version} (integer) - Version used when creating the mesh file@*
## @seealso{local_matrices}
## @end deftypefn

## Author: Arthur Clemente Giannotta
## Created: 2020-11-08

function [coordinates, topology, version] = read_msh (filename)
  # Auxiliary functions to convert a string into a cell of numbers
  function varargout = to_numbers(str)
    varargout = num2cell(sscanf(str, "%lf"));
  endfunction
  
  # Setups the default results
  coordinates = [];
  topology = [];
  
  # Type checking for all the input parameters
  if !ischar(filename) || length(filename) < 1
    printf("Invalid filename for function \"read_msh\": Should be a nonempty string\n");
    return;
  endif
  
  # Opens a file with read access
  # The try-catch block is here to ensure the file is opened successfully
  try
    file = fopen(filename, "r");
    
    assert(file != -1);
  catch err
    # Shows an error message if the file failed to be opened
    printf("\"read_msh\": Failed to open a file with name %s\n", filename);
    return;
  end_try_catch
  
  # The try-catch block is here to ensure the file is closed if an error occurs
  try
    # Reads until the file has ended
    while (!feof(file))
      identifier = fgetl(file);
      
      # Identifiers start with $
      if identifier(1) == '$'
        switch identifier(2:end)
          case "MeshFormat"
            [version, file_type, data_size] = to_numbers(fgetl(file));
            
            # Checks if the version used to format the mesh file is supported
            if version >= 2 && version < 3
              version = 2;
            elseif version >= 4 && version < 5
              version = 4;
            else
              printf("\"read_msh\": %s was formated in the unsupported version %.1f\n", filename, version);
              fclose(file);
              return;
            endif
          case "Nodes"
            # Each version has a different way to store the nodes data
            switch version
              case 2 # http://gmsh.info/doc/texinfo/gmsh.html#MSH-file-format-version-2-_0028Legacy_0029
                coordinates = zeros(str2num(fgetl(file)), 4); # Nodes have 1 identifier + 3 coordinates = 4 numbers
                
                for i = 1:length(coordinates)
                  coordinates(i, :) = sscanf(fgetl(file), "%lf");
                endfor
              case 4 # http://gmsh.info/doc/texinfo/gmsh.html#MSH-file-format
                [n_blocks, n_nodes, start_node, stop_node] = to_numbers(fgetl(file));
                
                coordinates = zeros(n_nodes, 4); # Nodes have 1 identifier + 3 coordinates = 4 numbers
                
                i = 0; # Current node index
                
                for j = 1:n_blocks
                  [id, tag, parametric, block_size] = to_numbers(fgetl(file));
                  
                  assert(parametric == 0, "Parametric mesh not supported");
                  
                  for k = 1:block_size
                    coordinates(i + k, 1) = str2num(fgetl(file));
                  endfor
                  
                  for k = 1:block_size
                    coordinates(++i, 2:end) = sscanf(fgetl(file), "%lf");
                  endfor
                endfor
            endswitch
          case "Elements"
            # Each version has a different way to store elements data
            switch version
              case 2 # http://gmsh.info/doc/texinfo/gmsh.html#MSH-file-format-version-2-_0028Legacy_0029
                topology = zeros(str2num(fgetl(file)), 5); # Tetrahedron have 1 identifier + 4 nodes = 5 numbers
                
                for i = 1:length(topology)
                  data = sscanf(fgetl(file), "%lf");
                  
                  ty = data(2);
                  n_tags = data(3);
                  id = data(3 + n_tags); # Tags are skipped (they are useless for the solver)
                  
                  assert(ty == 4, "Only tetrahedron elements are supported");
                  
                  topology(i, 1) = data(1);
                  topology(i, 2:end) = data(3 + n_tags + 1:end);
                endfor
              case 4 # http://gmsh.info/doc/texinfo/gmsh.html#MSH-file-format
                [n_blocks, n_elements, start_element, end_element] = to_numbers(fgetl(file));
                
                topology = zeros(n_elements, 5); # Tetrahedron have 1 identifier + 4 nodes = 5 numbers
                
                i = 0; # Current element index
                
                for j = 1:n_blocks
                  [id, tag, ty, block_size] = to_numbers(fgetl(file));
                  
                  assert(ty == 4, "Only tetrahedron elements are supported");
                  
                  for k = 1:block_size
                    topology(++i, :) = sscanf(fgetl(file), "%lf");
                  endfor
                endfor
            endswitch
        endswitch
      endif
    endwhile
  catch err
    # Shows a generic error message if something bad happened
    warning(err.message, err.identifier);
    printf("\"read_msh\": There may be some data in %s that was not read\n", filename);
    return;
  end_try_catch
  
  # Closes the file handle
  fclose(file);
endfunction
