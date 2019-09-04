load('../data/planeInfo.mat', 'p_in', 'p_out', 'n_vec', 'd', 'X_in', 'Y_in', 'Z_in');

r3 = n_vec;
r1 = [X_in(4,10)-X_in(1,1), Y_in(4,10)-Y_in(1,1),Z_in(4,10)-Z_in(1,1)]';
r1 = r1/norm(r1);
r2 = cross(r3, r1);

R1 = [r1 r2 r3];
T1 = [X_in(3,6), Y_in(3,6), Z_in(3,6)]';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DRAW A CUBOID ON THE PLANE %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EA: [Yaw(Z-axis);Pitch(y-axis);Roll(x-axis)] Euler/Rotation angles [radians]
EA = [0.3, 0, 0]; % tune angle to make the cuboid vertical to ground

% Calculate Sines and Cosines
c1 = cos(EA(1));	s1 = sin(EA(1));
c2 = cos(EA(2));	s2 = sin(EA(2));
c3 = cos(EA(3));	s3 = sin(EA(3));

% Calculate Matrix
R2 = [c1*c2           -c2*s1          s2
     c3*s1+c1*s2*s3  c1*c3-s1*s2*s3  -c2*s3
     s1*s3-c1*c3*s2  c3*s1*s2+c1*s3  c2*c3]';

alph = 0.4; % transparency value of cuboid
colr = 'g'; % Color of cuboid

%% Create Vertices
SL = [1;1;1]; % Length of Cuboid Side (SL - SideLength)
x = 0.5*SL(1)*[-1 1 1 -1 -1 1 1 -1]';
y = 0.5*SL(2)*[-1 -1 1 1 1 1 -1 -1]';
z = SL(3)*[0 0 0 0 -1 -1 -1 -1]';

%% Create Faces
facs = [1 2 3 4
        5 6 7 8
        4 3 6 5
        3 2 7 6
        2 1 8 7
        1 4 5 8];

%% Rotate and Translate Vertices
verts = zeros(3,8);
for i = 1:8
    verts(:,i) = R1*R2*[x(i);y(i);z(i)]+T1;
end

figure
plot3(p_out(:,1),p_out(:,2),p_out(:,3),'.b')
hold on
plot3(p_in(:,1),p_in(:,2),p_in(:,3),'.r')
rotate3d on

%% Draw the faces of the cuboid
patch('Faces',facs,'Vertices',verts','FaceColor',colr,'FaceAlpha',alph);

save_file = '../data/cuboidInfo.mat';
if ~exist(save_file, 'file')
    save(save_file, 'verts', 'facs', '-v7.3');
end

clear all
