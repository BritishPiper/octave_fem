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
output    = "Output/output.pos";
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
  endif
endfunction
```

## Approximate Points

Sometimes you want to find the closest approximated points in the mesh to a given set of real points. The script "approximate_points.m" was created for that purpose. For example, if we wanted to find the central points of the faces of a 0.3 x 0.3 x 0.3 cube which is centered at the origin, one would modify the script to:

```
mesh = "Meshes/mesh.msh";

points = [
  +0.15, 0, 0;
  -0.15, 0, 0;
  0, +0.15, 0;
  0, -0.15, 0;
  0, 0, +0.15;
  0, 0, -0.15;
];
```

The output of the closest nodes to the real points is done in the Octave console:

```
́Node |        Coordinates           |      Approximated Point      | Distance
 364 | +0.15000, +0.00000, +0.00000 | +0.15000, +0.00000, +0.00000 | 0.000000
 239 | -0.15000, +0.00000, +0.00000 | -0.15000, +0.00000, +0.00000 | 0.000000
 314 | +0.00000, +0.15000, +0.00000 | +0.00000, +0.15000, +0.00000 | 0.000000
 264 | +0.00000, -0.15000, +0.00000 | +0.00000, -0.15000, +0.00000 | 0.000000
 289 | +0.00000, +0.00000, +0.15000 | +0.00000, +0.00000, +0.15000 | 0.000000
 339 | +0.00000, +0.00000, -0.15000 | +0.00000, +0.00000, -0.15000 | 0.000000
 ```

The approximated points (Nodes 364, 239, 314, 264, 289 and 339) are the same as the real points in this example, yielding a distance of 0.0. This happens because the mesh contains the real points.

## Parallelism

The code is not optimal at all. The implementation of basic parallelism when calculating the local matrices was done to try and improve its usability. The commands "pkg install -forge parallel" and "pkg install -forge struct" must be executed in Octave for this to work. Parallelization can be enabled by commenting/uncommenting the lines:

```
# Parallel computation (faster, but requires pkg parallel)
global K_local;
par_local_matrices(coordinates, topology, @conductivity);

printf("\nLocal matrices computed with parallelism in %f seconds\n", toc(start)); start = tic;

# Serial computation
# K_local = local_matrices(coordinates, topology, @conductivity);

# printf("\nLocal matrices computed in %f seconds\n", toc(start)); start = tic;
```
