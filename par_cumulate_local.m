# Auxiliary function that cumulates the local matrices into the global matrix
function par_cumulate_local(parcell)
  global K_local;
  
  K_local(:, :, parcell{1}) = parcell{2};
endfunction
