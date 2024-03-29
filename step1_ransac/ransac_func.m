function [p_best,n_vec,ro_best,X_best,Y_best,Z_best]=ransac_func(p,no,k,t,d)
%% INPUT:
% no - smallest number of points required
% k - number of iterations
% t - threshold used to id a point that fits well
% d - number of nearby points required
%% OUTPUT:
% p_best - the points in the plane
% n_vec - the normal vector (a,b,c) of the plane
% ro_best - d in ax+by+cz-d=0
% X_best, Y_best, Z_best - representative points on the plane

	% Initialize variables
	iterations=0;
	% Until k iterations have occurrec
	while iterations < k
		ii=0;
		clear p_close dist p_new p_in p_out
		% Draw a sample of n points from the data
		perm = randperm(length(p));
		sample_in = perm(1:no);
		p_in = p(sample_in,:);
		sample_out = perm(no+1:end);
		p_out = p(sample_out,:);
		% Fit to that set of n points
		[n_est_in ro_est_in] = LSE(p_in);
		% For each data point oustide the sample
		for i=sample_out
			dist = dot(n_est_in,p(i,:)) - ro_est_in;
			%Test distance d to t
			abs(dist);
			if abs(dist) < t %If d<t, the point is close
				ii = ii + 1;
				p_close(ii,:) = p(i,:);
			end
		end
		p_new = [p_in; p_close];
		% If there are d or more points close to the plane
		if length(p_new) > d
			% Refit the plane using all these points
			[n_est_new ro_est_new X Y Z] = LSE(p_new);
			for iii = 1:length(p_new)
				dist(iii) = dot(n_est_new,p_new(iii,:)) - ro_est_new;
			end
			% Use the fitting error as error criterion
			error(iterations+1) = sum(abs(dist));
		else
			error(iterations+1) = inf;
		end
		if iterations > 1
			% Use the best fit from this collection
			if error(iterations+1) <= min(error)
				p_best = p_new;
				n_vec = n_est_new;
				ro_best = ro_est_new;
				X_best = X;
				Y_best = Y;
				Z_best = Z;
				error_best = error(iterations+1);
			end
		end
		iterations = iterations + 1;
		if mod(iterations,100)==0
			fprintf('RANSAC iteration [%d / %d] \n',iterations, k);
		end
	end
end