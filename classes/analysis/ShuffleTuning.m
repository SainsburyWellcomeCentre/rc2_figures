classdef ShuffleTuning < handle

    properties
        
        n_reps = 1000
        x
        tuning
        n_bins
        n_trials
        
        rsq
        beta
        
        rsq_shuff
        beta_shuff
        shuff_tuning
        shuff_sd
        shuff_n
        
        p
    end
    
    
    
    methods
        
        function obj = ShuffleTuning(tuning, x)
            
            obj.x = x(:); % n bins x 1
            obj.tuning = tuning; % n bins x n trials
            obj.n_bins = size(obj.tuning, 1);
            obj.n_trials = size(obj.tuning, 2);
            
            % fit to data R^2
            x_ = repmat(obj.x, 1, obj.n_trials);
            [obj.rsq, obj.beta] = obj.get_rsq(x_(:), tuning(:));
                
            obj.get_shuffled_rsq();
            
            if isnan(obj.rsq)
                obj.p = nan;
            else
                p_up = sum(obj.rsq_shuff > obj.rsq)/obj.n_reps;
                p_down = sum(obj.rsq_shuff < obj.rsq)/obj.n_reps;
                obj.p = min(p_up, p_down);
            end
        end
        
        
        
        function get_shuffled_rsq(obj)
            
            rng(1);
            x_ = repmat(obj.x, 1, obj.n_trials);
            obj.rsq_shuff = nan(1, obj.n_reps);
            obj.beta_shuff = nan(obj.n_reps, 2);
            obj.shuff_tuning = nan(obj.n_bins, obj.n_reps);
            obj.shuff_sd = nan(obj.n_bins, obj.n_reps);
            obj.shuff_n = nan(obj.n_bins, obj.n_reps);
            
            for rand_i = 1 : obj.n_reps
                I = randi(numel(obj.tuning), size(obj.tuning));
                new_tuning = obj.tuning(I);
                
                [obj.rsq_shuff(rand_i), ...
                    obj.beta_shuff(rand_i, :)] = obj.get_rsq(x_(:), new_tuning(:));
                
                obj.shuff_tuning(:, rand_i) = nanmean(new_tuning, 2);
                obj.shuff_sd(:, rand_i) = nanstd(new_tuning, [], 2);
                obj.shuff_n(:, rand_i) = sum(~isnan(new_tuning), 2);
            end
        end
        
        
        
        function [rsq, beta] = get_rsq(obj, x, tuning)
            
            x(isnan(tuning)) = [];
            tuning(isnan(tuning)) = [];
            
            beta = polyfit(x, tuning, 1);
            yfit =  beta(1)*x + beta(2);
            yresid = tuning - yfit;
            SSresid = sum(yresid.^2);
            SStotal = (length(tuning)-1) * var(tuning);
            rsq = 1 - SSresid/SStotal;
        end
    end
end
