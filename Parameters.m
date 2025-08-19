classdef Parameters < handle
    properties
        % Main simulation parameters
        format (1,1) double = 1;          % Modulation format
        Rb (1,1) double = 100e9;          % Bit rate [bits/s]
        fs (1,1) double;                  % Sampling frequency [Hz]
        % Modulation setup
        FormatStr (1,1) string = "QAM-4";
        M (1,1) double = 4;               % Modulation order
        k (1,1) double;                   % Bits per symbol
        a (1,1) double = 1.0;             % Normalization constant
        Boundaries;                       % Decision boundaries function handle
        % Bit & symbol counts
        Nbits (1,1) double = 2^15;
        Nsym (1,1) double;                % Number of symbols
        % Timing parameters
        Rs (1,1) double;                  % Symbol rate [symbols/s]
        Ts (1,1) double;                  % Symbol period [s]
        ts (1,1) double;                  % Sampling period [s]
        sps (1,1) double;                 % Samples per symbol
        % Simulation state
        t_k (1,:) double = [];            % Transmitted symbols
        r_k (1,:) double = [];            % Received symbols
        current_SNR (1,1) double = 0.0;   % Current SNR value (scalar)
        BER (1,1) double = 0.0;
        OriginalBits (1,:) double = [];   % Original transmitted bits
        % Channel impulse responses
        h (1,:) double;                   % Selected channel impulse response
    end

    properties (Constant)
        % Predefined channel impulse responses
        ch1 = [1.0, 0.0, 0.0];
        ch2 = [0.447, 0.894, 0.0];
        ch3 = [0.209, 0.995, 0.209];
        ch4 = [0.260, 0.930, 0.260];
        ch5 = [0.304, 0.903, 0.304];
        ch6 = [0.341, 0.876, 0.341];
        % Default SNR range
        DefaultSNRRange = -1:1:12;         % dB
    end

    methods
        function obj = Parameters()
            % Constructor: Initialize derived parameters
            obj.fs = 8 * obj.Rb;
            obj.k = log2(obj.M);
            obj.Nsym = floor(obj.Nbits / obj.k);
            obj.Rs = obj.Rb / obj.k;
            obj.Ts = 1.0 / obj.Rs;
            obj.ts = 1.0 / obj.fs;
            obj.sps = obj.fs / obj.Rs;
            % Set default channel (CH1)
            obj.set_channel(1);
        end

        function set_param(obj, name, value)
            if isprop(obj, name)
                % Special handling for current_SNR
                if strcmp(name, 'current_SNR') && ~isscalar(value)
                    error('current_SNR must be a scalar value');
                end
                obj.(name) = value;
            else
                error('Parameter %s does not exist.', name);
            end
        end

        function value = get_param(obj, name)
            if isprop(obj, name)
                value = obj.(name);
            elseif strcmp(name, 'SNR_range')
                value = obj.DefaultSNRRange;  % Return default SNR range
            else
                error('Parameter %s does not exist.', name);
            end
        end

        function set_channel(obj, channel_choice)
            % Set channel impulse response based on channel_choice
            channels = containers.Map({1, 2, 3, 4, 5, 6}, ...
                {obj.ch1, obj.ch2, obj.ch3, obj.ch4, obj.ch5, obj.ch6});
            if isKey(channels, channel_choice)
                obj.h = channels(channel_choice);
                fprintf('Selected Channel CH%d impulse response h: [%s]\n', ...
                    channel_choice, num2str(obj.h));
            else
                error('Invalid channel choice. Must be 1-6.');
            end
        end
    end
end
