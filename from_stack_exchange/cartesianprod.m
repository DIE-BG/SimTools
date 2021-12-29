function out = cartesianprod(varargin)
%% CARTESIANPROD
%
% Wrapper for meshgrid(), which creates all combinations of the elements of
% the vectors stored in the cellarray 'fields'.  The output is either i) a  
% cellarray of combinations, each given as a string where the original 
% elements are separated by 'delim', or ii) a row-indexed matrix of 
% combinations of the original elements.  All component vectors must be of 
% the same type (all cell arrays or all doubles).  
% See the following examples.
%
% Example 1:
% fields{1} = {'a';'b'};
% fields{2} = {'c';'d';'e'};
% fields{3} = {'f';'g'};
% delim = '_';
% out = cartesianprod(fields,delim);
% out =
%     'a_c_f'
%     'a_c_g'
%     'a_d_f'
%     'a_d_g'
%     'a_e_f'
%     'a_e_g'
%     'b_c_f'
%     'b_c_g'
%     'b_d_f'
%     'b_d_g'
%     'b_e_f'
%     'b_e_g'
%
% Example 2:
% fields{1} = {'a';'b'};
% fields{2} = {'c';'d';'e'};
% fields{3} = {'f';'g'};
% out = cartesianprod(fields);
% out = 
% 
%     'a'    'c'    'f'
%     'a'    'c'    'g'
%     'a'    'd'    'f'
%     'a'    'd'    'g'
%     'a'    'e'    'f'
%     'a'    'e'    'g'
%     'b'    'c'    'f'
%     'b'    'c'    'g'
%     'b'    'd'    'f'
%     'b'    'd'    'g'
%     'b'    'e'    'f'
%     'b'    'e'    'g'
%
% Example 3:
% fields{1} = [1;2];
% fields{2} = [3;4;5];
% fields{3} = [6;7];
% out = cartesianprod(fields);
% out = 
%      1     4     6
%      1     4     7
%      1     5     6
%      1     5     7
%      2     4     6
%      2     4     7
%      2     5     6
%      2     5     7
%      3     4     6
%      3     4     7
%      3     5     6
%      3     5     7


%% Error Check

classes = cellfun(@(x)class(x),varargin{1},'UniformOutput',false);
if ~(all(strcmp(classes,'cell')) || all(strcmp(classes,'double')))
    error('cartesianproduct:mixedTypes',...
        ['Error. \nFactors must be either all of class cell'...
    ' or all of class double']);
end

%% Vector Version (cellarray input only)

if nargin==2
    fields = varargin{1};
    delim = varargin{2};
    
    % check if there is anything to do
    if numel(fields)==1
        out = fields{1};
        return
    end
    
    % create cellarray of indices for use in meshgrid
    vecs = cellfun(@(x)1:numel(x),fields,'UniformOutput',false);
    
    % function is iterative, so initialize first tensor product manually
    vec1 = 1:numel(fields{1});
    vec2 = 1:numel(fields{2});
    [p,q] = meshgrid(vec1, vec2);
    pairs = [fields{1}(p(:)) fields{2}(q(:))];
    temp = strcat(pairs(:,1),delim,pairs(:,2));
    
    % check if tensor product has order 3 or higher
    if numel(fields)==2
        out = temp;
        return
    end
    
    % iteratively build tensor product
    for i=2:numel(vecs)-1
        
        % vectorized index of elements of previous loop iteration
        vec = 1:numel(temp);
        
        % new index combination
        [p,q] = meshgrid(vec, vecs{i+1});
        
        % create new combinations from old combos and elements of (i+1)st vect
        temp2 = fields{i+1};
        pairs = [temp(p(:)) temp2(q(:))];
        temp = strcat(pairs(:,1),delim,pairs(:,2));
        
    end
    
    out = temp;
    
else
%% Matrix Version (double or cellarray input)
    
    fields = varargin{1};
    
    % check if there is anything to do
    if numel(fields)==1
        out = fields{1};
        return
    end
    
    % create cellarray of indices for use in meshgrid
    vecs = cellfun(@(x)1:numel(x),fields,'UniformOutput',false);
    
    % function is iterative, so initialize first tensor product manually
    vec1 = 1:numel(fields{1});
    vec2 = 1:numel(fields{2});
    [p,q] = meshgrid(vec1, vec2);
    pairs = [fields{1}(p(:)) fields{2}(q(:))];
    temp = pairs;
    
    if numel(fields)==2
        out = pairs;
        return
    end
    
    % iteratively build tensor product
    for i=2:numel(vecs)-1

        % vectorized index of elements of previous loop iteration
        vec = 1:size(temp,1);
        
        % new index combination
        [p,q] = meshgrid(vec, vecs{i+1});
        
        % create new combinations from old combos and elements of (i+1)st vect
        temp2 = fields{i+1};
        temp = [temp(p(:),:) temp2(q(:))];
   
    end
    
    out = temp;
end



