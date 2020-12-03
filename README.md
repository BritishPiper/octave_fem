# Generalized Poisson FEM in Octave
An implementation of the Finite Element Method for the solution of the Generalized Poisson Equation using Octave. This was done as the final exercise for the course "PME3534 - Técnicas Experimentais e Computacionais em Biomecânica e Sistemas Vasculares" at USP (University of São Paulo). All the code is open source, published under the GNU license.

LaTEX equation being solved:
$\Delta \cdot (\epsilon\ \Delta V) = -\frac{\rho}{\epsilon_0}}$

## Usage
The main script to be executed is "fem.m", which should be modified as desired. Examples for the mesh and for the generated output can be found at the folders "Meshes" and "Output". ".geo", ".msh" and ".pos" files should be opened using GMSH.

## Mesh File

```
mesh = "Meshes/mesh.msh";
```

The file "mesh.msh" is any tetrahedral mesh generated using GMSH, exported as version ASCII 2 or 4.

## Boundary Conditions

```
dirichlet = "Meshes/Dirichlet.dat";
neumann   = "Meshes/Neumann.dat";
```

The first column of the matrices of the boundary conditions is the number of the nodes where the condition is applied. The second column is the value of the condition, for example, the Neumann value specifies the electrical current in a given node and the Dirichlet specifies a fixed voltage in a node.

## Output Files

```
output    = "Output/output.pos;
results   = "Output/results.txt";
```

## Conductivity (Custom For Each Element):

```
function k = conductivity(element)
  k_object = 0.01 * eye(3); # (Ohm.m)^-1
  k_domain = 1.00 * eye(3); # (Ohm.m)^-1
  
  if element <= 1536 # Inside of the object
    k = k_object;
  else # Inside of the domain, outside of the object
    k = k_domain;
  dndif
endfunction
```
