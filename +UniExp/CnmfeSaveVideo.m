function Ybg=CnmfeSaveVideo(neuron,Y,Ybg,Ysignal,save_avi,options)
arguments
	neuron
	Y
	Ybg
	Ysignal
	save_avi
	options.t_begin = 1
	options.t_end = size(neuron.C, 2)
	options.kt = 1
	options.center_ac = median(max(neuron.A,[],1)'.*max(neuron.C,[],2));
	options.range_ac
	options.range_Y
	options.multi_factor
	options.avi_filename
end

%% data preparation
Y = neuron.reshape(Y, 2);
Yac = neuron.reshape(neuron.A*neuron.C, 2);
Ybg = neuron.reshape(Ybg, 2);
Ysignal = neuron.reshape(Ysignal, 2);
figure('position', [0,0, 600, 400]);
range_res = [-1,1]*options.center_ac;
if ~isfield(options,'range_ac')
	options.range_ac = options.center_ac*1.01+range_res;
end
if ~isfield(options,'range_Y')
	if ~isfield(options,'multi_factor')
		temp = quantile(Y(randi(numel(Y), 10000,1)), [0.01, 0.98]);
		options.multi_factor = ceil(diff(temp)/diff(options.range_ac));
		%     else
		%         temp = quantile(Y(randi(numel(Y), 10000,1)), 0.01);
	else
		temp = quantile(Y(randi(numel(Y), 10000,1)), 0.01);
	end
	center_Y = temp(1) + options.multi_factor*options.center_ac;
	options.range_Y = center_Y + range_res*options.multi_factor;
end
%% create avi file
if save_avi
	avi_file = VideoWriter(options.avi_filename);
	if ~isnan(neuron.Fs)
		avi_file.FrameRate= neuron.Fs/options.kt;
	end
	avi_file.open();
end

%% add pseudo color to denoised signals
[K, T]=size(neuron.C);
% draw random color for each neuron
% tmp = mod((1:K)', 6)+1;
Y_mixed = zeros(neuron.options.d1*neuron.options.d2, T, 3);
temp = prism;
% temp = bsxfun(@times, temp, 1./sum(temp,2));
col = temp(randi(64, K,1), :);
for m=1:3
	Y_mixed(:, :, m) = neuron.A* (diag(col(:,m))*neuron.C);
end
Y_mixed = uint16(Y_mixed/(1*options.center_ac)*65536);
%% play and save
ax_y =   axes('position', [0.015, 0.51, 0.3, 0.42]);
ax_bg=   axes('position', [0.015, 0.01, 0.3, 0.42]);
ax_signal=    axes('position', [0.345, 0.51, 0.3, 0.42]);
ax_denoised =    axes('position', [0.345, 0.01, 0.3, 0.42]);
ax_res =    axes('position', [0.675, 0.51, 0.3, 0.42]);
ax_mix =     axes('position', [0.675, 0.01, 0.3, 0.42]);
for m=options.t_begin:options.kt:options.t_end
	axes(ax_y); cla;
	imagesc(Ybg(:, :,m)+Ysignal(:, :, m), options.range_Y);
	%     set(gca, 'children', flipud(get(gca, 'children')));
	title('Raw data');
	axis equal off tight;

	axes(ax_bg); cla;
	imagesc(Ybg(:, :, m),options.range_Y);
	%     set(gca, 'children', flipud(get(gca, 'children')));
	axis equal off tight;
	title('Background');

	axes(ax_signal); cla;
	imagesc(Ysignal(:, :, m), options.range_ac); hold on;
	%     set(gca, 'children', flipud(get(gca, 'children')));
	title(sprintf('(Raw-BG) X %d', options.multi_factor));
	axis equal off tight;

	axes(ax_denoised); cla;
	imagesc(Yac(:, :, m), options.range_ac);
	%     imagesc(Ybg(:, :, m), [-50, 50]);
	title(sprintf('Denoised X %d', options.multi_factor));
	axis equal off tight;

	axes(ax_res); cla;
	imagesc(Ysignal(:, :, m)-Yac(:, :, m), range_res);
	%     set(gca, 'children', flipud(get(gca, 'children')));
	title(sprintf('Residual X %d', options.multi_factor));
	axis equal off tight;
	%         subplot(4,6, [5,6,11,12]+12);

	axes(ax_mix); cla;
	imagesc(neuron.reshape(Y_mixed(:, m,:),2));  hold on;
	title('Demixed');
	text(1, 10, sprintf('Time: %.2f second', m/neuron.Fs), 'color', 'w', 'fontweight', 'bold');

	axis equal tight off;
	%     box on; set(gca, 'xtick', []);
	%     set(gca, 'ytick', []);

	drawnow();
	if save_avi
		temp = getframe(gcf);
		temp = imresize(temp.cdata, [400, 600]);
		avi_file.writeVideo(temp);
	end
end

if save_avi
	avi_file.close();
end
end