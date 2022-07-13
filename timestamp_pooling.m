%% ����ͬ����������ת���ɾ�����ͬ��״�ĸ�ʽ
function fault_start = timestamp_pooling()
filename = 'E:\Zotero\Paper\storage\97GYVSG7\alfa-dataset-tools\dataset\carbonZ_2018-07-30-16-39-00_2_engine_failure/carbonZ_2018-07-30-16-39-00_2_engine_failure.mat';
Sequence = sequence(filename);

start_time = Sequence.GetStartTime();
%% 
roll = Sequence.GetTopicByName('mavros_nav_info_roll');
roll_feat = roll.Data.measured;
pitch = Sequence.GetTopicByName('mavros_nav_info_pitch');
pitch_feat = pitch.Data.measured;
yaw = Sequence.GetTopicByName('mavros_nav_info_yaw');
yaw_feat = yaw.Data.measured;

%%
vel = Sequence.GetTopicByName('mavros_nav_info_velocity');
airspeed = Sequence.GetTopicByName('mavros_nav_info_airspeed');
velx_feat = vel.Data.meas_x;
vely_feat = vel.Data.meas_y;
velz_feat = vel.Data.meas_z;
air_feat = airspeed.Data.measured;

%% mavros_nav_info_errors �����ݵ�� mavros_nav_info_roll(pitch,yaw)����509�����ʿ���ֱ��ƴ�������Ǻ���
error = Sequence.GetTopicByName('mavros_nav_info_errors');
xtrack_err = error.Data.xtrack_error;
aspd_error = error.Data.aspd_error;
alt_err = error.Data.alt_error;

%% 
times_roll = roll.Data.time_recv - start_time;
times_velx = vel.Data.time_recv - start_time;

headers1 = {'time','roll','pitch','yaw','xtrack_err','aspd_error','alt_err'};
angle_data = table(times_roll, roll_feat, pitch_feat, yaw_feat, xtrack_err, aspd_error, alt_err, 'VariableNames', headers1);

headers2 = {'time','vel_x','vel_y','vel_z','airspeed'};
vel_data = table(times_velx, velx_feat, vely_feat, velz_feat, air_feat, 'VariableNames', headers2);

Timestamp = 0:0.250:times_roll(end); 
for i=1:length(Timestamp)
    time_slice_roll = find(angle_data.time>0+Timestamp(i) & angle_data.time<=0.250+Timestamp(i)); %% ��������
    time_slice_vel = find(vel_data.time>0+Timestamp(i) & vel_data.time<=0.250+Timestamp(i));
    feat_roll = length(time_slice_roll);
    feat_vel = length(time_slice_vel);
    n = feat_roll-feat_vel;
    if n>0
        random_sort = time_slice_roll(randperm(feat_roll));
        random_sort = random_sort(1:n,1);
        % ɾ��һ�������ڵ����ݵ�
        angle_data(random_sort,:) = [];
    elseif n<0
        random_sort = time_slice_vel(randperm(feat_vel));
        random_sort = random_sort(1:abs(n),1);
        % ɾ��һ�������ڵ����ݵ�
        vel_data(random_sort,:) = [];
    else
    end
end
concat_data = [angle_data, vel_data(:,2:end)];
% % save('10_05_3_engine_failure_with_emr_traj.mat','concat_data');
% concat_data = vel_data(:,2:end);
save('7_30_engine_2.mat','concat_data');

%% ��table����д�뵽���ӱ��excel��, ʹ��writetable����
file_name = '7_30_engine_2.xlsx';
writetable(concat_data,file_name,'sheet',1,'Range','A1');

%% ���ǩ
% ������Ͽ�ʼʱ��
% fault_start = Sequence.Topics.failure_status_engines.time_recv(1)-start_time;
fault_start = 1;  % ��� no_failure ʱ���� fault_start = 1
end
