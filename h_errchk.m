function h_errchk(read_count,expected_count,varname,filename)

if read_count ~= expected_count
  error(sprintf('could not read %s from header of file(%s)',varname,filename));
end
