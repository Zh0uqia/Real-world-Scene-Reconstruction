internal_file = '../data/cameras.txt';
external_file = '../data/images.txt';
img_dir = '../img_input';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read camera internal parameter %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inter_para = zeros(1,4); % internal parameter
if ~exist(internal_file, 'file')
    assert('Camera internal parameter file doesn''t exist...');
end
fid = fopen(internal_file);
%% READ FILE LINE BY LINE
tline = fgetl(fid);
while ischar(tline)
    % skip line if empty or comment
    if isempty(tline) || strcmp(strtrim(tline(1)), '#')
        tline = fgetl(fid); continue;
    end    
    % split parameter into variable name and value
    C = strsplit(tline,' ');
	width = str2num(C{3});
	height = str2num(C{4});
	if C{2}=='SIMPLE_RADIAL'
		for i = 1:4
			inter_para(i) = str2num(C{i+4}); % [f, cx, cy, k]
		end
	end
    % read next line
    tline = fgetl(fid);
end
fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read external parameters of each image %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
num_img = 0;
ext_para = zeros(1,7); % external parameter
if ~exist(external_file, 'file')
    assert('External parameter file doesn''t exist...');
end
fid = fopen(external_file);
%% READ FILE LINE BY LINE
tline = fgetl(fid);
while ischar(tline)
    % skip line if empty or comment
    if isempty(tline) || strcmp(strtrim(tline(1)), '#')
        tline = fgetl(fid); continue;
    end    
    % split parameter into variable name and value
    C = strsplit(tline,' ');
	if strcmp(C{10}(end-2:end), 'JPG')
		num_img = num_img + 1;
		for i = 2:8
			ext_para(i-1) = str2num(C{i});
		end
		Rot{num_img} = quat2rotm(ext_para(1:4)); % external parameters
		Tran{num_img} = ext_para(5:7)';
		img_name{num_img} = C{10};
	end	
    % read next line
    tline = fgetl(fid);
end
fclose(fid);

%% load the scene coordinates of the vertices
load('../data/cuboidInfo.mat', 'verts', 'facs'); % facs: index of vertex for each face, size (6,4) (face x vertex)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project the cuboid on each image %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:num_img
	% Transfer to local camera coordinate system
	verts_new{i} = Rot{i}*verts + Tran{i};
	verts_cam{i} = verts_new{i}(1:2, :)./verts_new{i}(3, :);
	% Transfer to pixel coordinate according to SimpleRadialCameraModel
	% Refer to https://github.com/colmap/colmap/blob/master/src/base/camera_models.h
	u = verts_cam{i}(1,:);
	v = verts_cam{i}(2,:);
	r2 = u.*u + v.*v;
	radial = inter_para(4) .* r2;
	du = u .* radial; % distortion
	dv = v .* radial; % distortion
	x = u + du;
	y = v + dv;
	x = inter_para(1).*x + inter_para(2); % transform to image coordinates
	y = inter_para(1).*y + inter_para(3); % transform to image coordinates
	verts_prj{i} = [x; y]';	
	% Load the original image
	f = figure;
	imOrig = imread(fullfile(img_dir, img_name{i}));
	imshow(imOrig);
	hold on
	% Sort the depth of all faces, and according change the order of drawing face
	depth = zeros(1,6);
	for j = 1:6
		depth(j) = mean(verts_new{i}(3, facs(j,:))); % average depth of the four vertices
	end
	[d_sort, idx] = sort(depth, 'descend');
	facs_new = facs(idx, :);
	% Draw the faces
	colr = [1:8]';
	patch('Faces',facs_new,'Vertices',verts_prj{i},'FaceVertexCData',colr,'FaceColor','flat','LineStyle','none','FaceAlpha', 0.98);
	% Save the AR image
	saveas(f,strcat('../img_output/result',int2str(i),'.png'))
	pause(1)
end
