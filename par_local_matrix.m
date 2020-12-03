# Auxiliary parallel function that setups a single local matrix
function parcell = par_local_matrix(element, V, D)
  # Setups the parallel cell, which contains the element id and the local matrix
  parcell = cell(2, 1);
  parcell{1} = element;
  
  # Pre-allocates memory for the cofactor matrix
  B = zeros(3, 4);
  
  # Calculates the inverse matrix
  
  # This line works, is fast, but the inverse function is unreliable error-wise
  # B = inv(V)(2:end, :);
  
  # Calculates 6 * volume
  v6 = det(V);
  
  # Calculates the adjugate matrix (?, ?, ? coefficients)
  for i = 1:4
    for j = 2:4
      # Eliminate the i-th row and j-column
      A = V([1:i-1 i+1:4], [1:j-1 j+1:4]);
      
      # i and j are inverted since the adjugate is the transpose of the cofactor matrix
      if mod(i + j, 2) == 0
        B(j - 1, i) = det(A);
      else
        B(j - 1, i) = -det(A);
      endif
    endfor
  endfor
  
  # In reality, B = B / v6, but we don't calculate it for speed and precision
  # To compensate for this, the next equation is divided by 6 * v6 instead of multiplied by v6 / 6
  
  # Computes the local matrix from v6, D and B
  parcell{2} = (B' * D * B) / (6 * v6);
endfunction
