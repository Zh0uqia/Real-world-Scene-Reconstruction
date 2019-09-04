point3d_file = '../data/points3D.txt';

P = [];
this_p = zeros(1,3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read 3D Point Coordinates to P %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist(point3d_file, 'file')
    assert('3D points file doesn''t exist...');
end
fid = fopen(point3d_file);
%% READ FILE LINE BY LINE
tline = fgetl(fid);
while ischar(tline)
    % skip line if empty or comment
    if isempty(tline) || strcmp(strtrim(tline(1)), '#')
        tline = fgetl(fid); continue;
    end    
    % split parameter into variable name and value
    C = strsplit(tline,' ');
	% get 3D point coordinate
	for i = 2:4
		this_p(i-1) = str2num(C{i});
	end
	P = [P; this_p];    
    % read next line
    tline = fgetl(fid);
end
%% CLOSE FILE
fclose(fid);

num_p = size(P,1);

no = 3; % smallest number of points required
k = 4000; % number of iterations
t = 0.2; % threshold used to id a point that fits well
d = 8000; % number of nearby points required

% p_in - the points on the plane
% n_vec - the normal vector (a,b,c) of the plane
% d - which in ax+by+cz=d
% X_in, Y_in, Z_in - representative points on the plane
[p_in, n_vec, d, X_in, Y_in, Z_in] = ransac_func(P,no,k,t,d);
p_out = setdiff(P, p_in, 'rows'); % the points out of the plane

save_file = '../data/planeInfo.mat';
if ~exist(save_file, 'file')
    save(save_file, 'p_in', 'p_out', 'n_vec', 'd', 'X_in', 'Y_in', 'Z_in','-v7.3');
end

figure
plot3(p_out(:,1),p_out(:,2),p_out(:,3),'.b')
hold on
plot3(p_in(:,1),p_in(:,2),p_in(:,3),'.r')
rotate3d on

clear all