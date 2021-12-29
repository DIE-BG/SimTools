function plot_compare_pred(MODEL, varargin)


model_name = fieldnames(MODEL.FORECAST_SIMS);


 p = inputParser;
    addParameter(p, 'SavePath', fullfile(userpath, 'temp'));
    addParameter(p, 'PeriodEval', 1);
    addParameter(p, 'Color', [0,0,1;1,0,0;0,1,0]);
    addParameter(p, 'VariableToPlot', 'v_cpi_sub');
    addParameter(p, 'EndHist', {});
parse(p, varargin{:});
params = p.Results; 

if ~isfolder(params.SavePath)
    mkdir(params.SavePath)
else
%     rmdir(params.SavePath, 's')
    mkdir(params.SavePath)
end


params.FirstDate = MODEL.FORECAST_SIMS.(MODEL.NAME).JF_pred_sim{1}.i.Range(1);
    
params.PredRange = MODEL.FORECAST_SIMS.(MODEL.NAME).JF_pred_sim{1}.i.Range(2): ...
    MODEL.FORECAST_SIMS.(MODEL.NAME).JF_pred_sim{1}.i.Range(end);



plot_var = params.VariableToPlot;

if ~isempty(params.EndHist)
    MODEL.data_mr = dbclip(MODEL.data_mr, MODEL.DATES.hist_start:params.EndHist);
end
hist = MODEL.data_mr.(plot_var);

pred = repmat(hist, 1, length(model_name)); % Para que tenga toda la data de la historia.

for m = 1:length(model_name)
   
    if strcmp(regexp(model_name{m}, 'mms4', 'match', 'once'), 'mms4') && strcmp(params.VariableToPlot, 'v_cpi_sub')
        plot_var = 'v_cpi';
    elseif strcmp(regexp(model_name{m}, 'mms4', 'match', 'once'), 'mms4') && strcmp(params.VariableToPlot, 'v_cpi')
        plot_var = 'v_cpi_sub';
    else
        plot_var = params.VariableToPlot;
    end

    for t = 1:length(params.PredRange)

        try
            temp_pred_date = dbclip(...
                MODEL.FORECAST_SIMS.(model_name{m}).JF_pred_sim{t}, ...
                params.PredRange(t:end)...
            ).(plot_var).Range(params.PeriodEval*4);
            
            if t == 1
                end_hist = temp_pred_date - 1;
            end

            temp_pred_data = dbclip(...
                MODEL.FORECAST_SIMS.(model_name{m}).JF_pred_sim{t}, ...
                params.PredRange(t:end)...
            ).(plot_var).Data(params.PeriodEval*4);
    
            pred(temp_pred_date, m) = temp_pred_data;
        catch
            % Si excede el índice, no hará nada.
        end
    end
end

if ~isempty(params.EndHist)
    pred = resize(pred, MODEL.DATES.hist_start:params.EndHist);
end

figure('Position', [1 42.0182 1.6756e+03 825.6000])

plot( ...
    pred, ...
    'LineWidth', 2, ...
    'Marker', 's', ...
    'LineStyle', '-.')

set(gca, 'ColorOrder', params.Color)


hold on
vline(end_hist, ...
    'LineWidth', 1, ...
    'LineStyle', '--');

plot( ...
    hist, ...
    'w', ...
    'LineWidth', 5, ...
    'HandleVisibility','off')

plot( ...
    hist, ...
    'k', ...
    'LineWidth', 3, ...
    'Marker', 's')



hold off




legend(vertcat(model_name, {'Historia'}), ...
    'Interpreter', 'none')

if params.PeriodEval == 1
    temp_year = 'Año';
else
    temp_year = 'Años';
end



if ~any(0 >= get(gca, 'ylim'))
    y_lim = get(gca, 'ylim');
    ylim([0, y_lim(2)])
end


title(sprintf("%s \n Pronósticos a %i %s", ...
    params.VariableToPlot,...
    params.PeriodEval, ...
    temp_year...
    ), ...
    'Interpreter', 'none', ...
    'FontSize', 15)


saveas(gcf, ...
        fullfile(params.SavePath, ...
            sprintf("%s_eval_%i.png", params.VariableToPlot, params.PeriodEval)...
        ))


close all
end



