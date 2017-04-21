% Simple visual odometry plotting from scratch, written as an exercise

clear all;
close all;
dbclear if error;   % Disable pausing on error

% Make sure you set the 'is_kitti' flag depending on what dataset you're reading!
% img_dir     = '/Users/andrei/Datasets/karlsruhe/2010_03_09_drive_0019';

% The 77 frame sequence #52 is particularly challenging, because it features
% the car stopping at a red light surrounded by other vehicles, while a large
% truck on the right starts turning right, confusing the VO system.
img_dir = '/Users/andrei/Datasets/kitti/2011_09_26/2011_09_26_drive_0052_sync';
% img_dir = '/Users/andrei/Datasets/kitti/2011_09_26/2011_09_26_drive_0005_sync';

param.f     = 645.2;
param.cu    = 635.9;
param.cv    = 194.1;
param.base  = 0.571;    % Stereo rig baseline, in meters.
first_frame = 0;
last_frame  = 77;
% last_frame = 50;

visualize_odometry_3d = false;
% If true, expects the folder to have the structure of a standard KITTI
% sequence. Otherwise, Karlsruhe folder structure is assumed.
is_kitti = true;

param.multi_stage = 1;
param.ransac_iters = 250;   % Default is 200
param.match_disp_tolerance = 1;   % Default is 2

% param.half_resolution = 1;
% param.refinement = 1;

visualOdometryStereoMex('init', param);
fprintf('Stereo visual odometry code initialized successfully.\n');

figure;
% xlim([-10, 10]);
% ylim([  0, 20]);

% 'process(I1, I2, [replace])', 'process_matched(NxM)', 'num_matches()',
% 'get_matches()', 'num_inliers()', 'get_inliers()', 'get_indices()' (indices of
% matches (in what?)), 'close'.

currentPose = eye(4);
t = currentPose(1:3, 4);

for i = first_frame:last_frame
  tic;
  if is_kitti
    left_path = sprintf('%s/image_00/data/%010d.png', img_dir, i);
    right_path = sprintf('%s/image_01/data/%010d.png', img_dir, i);
  else
    left_path = sprintf('%s/I1_%06d.png', img_dir, i);
    right_path = sprintf('%s/I2_%06d.png', img_dir, i);
  end
  left = imread(left_path);
  right = imread(right_path);
%   fprintf('Image loading: %.4f\n', toc);
  
%   tic
  transform = visualOdometryStereoMex('process', left, right);
  p_matched = visualOdometryStereoMex('get_matches');
  currentPose = currentPose * inv(transform);
  t_new = currentPose(1:3, 4).';
%   fprintf('Visual odometry: %.4f\n', toc);
  
%   tic
  % Hand-tweaked subplot size to optimize space usage.
  sp = subplot(4, 2, [1, 2], 'Position', [0.1, 0.75, 0.85, 0.25]);

  % Render sparse scene flow in real time for visualization purposes.
  plotMatch(left, p_matched, 2);
  
  subplot(4, 2, 3:8);
  hold on;
  
  if visualize_odometry_3d
    scatter3(t_new(1), t_new(2), t_new(3), 'k');
    plot3([t(1), t_new(1)], [t(2), t_new(2)], [t(3), t_new(3)], '--k');
  else
    scatter(t_new(1), t_new(3), 'k');
    plot([t(1), t_new(1)], [t(3), t_new(3)], '--k');
  end
  
%   fprintf('Plotting: %.4f\n', toc);

  pause(0.001);
  refresh;
  t = t_new;
  frame_delta = toc;
  if mod(i + 1, 10) == 0
    fprintf('Total: %.4f @ %.2f FPS\n', frame_delta, 1/frame_delta);
  end
end

visualOdometryStereoMex('close', param);
fprintf('Stereo visual odometry code shut down successfully.\n');