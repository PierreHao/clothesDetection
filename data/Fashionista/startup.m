function startup
%STARTUP Initializes environment.
  root = fileparts(mfilename('fullpath'));
  addpath(fullfile(root, 'lib'));
  for d = dir(fullfile(root, 'lib'))'
    if d.isdir && d.name(1) ~= '.' &&  d.name(1) ~= '+'
      addpath(fullfile(root, 'lib', d.name));
    end
  end
end
