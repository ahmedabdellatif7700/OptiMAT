classdef ConfigERx < handle
    properties
        params Parameters;  % Parameters object
        format (1,1) double = 1;  % Modulation format (1 = QPSK)
    end

    methods
        function obj = ConfigERx(params, format)
            % Constructor
            if nargin < 2
                format = 1;  % Default to QPSK
            end
            obj.params = params;
            obj.format = format;
            obj.configure_rx();
        end

        function configure_rx(obj)
            % Configure receiver for the given modulation format
            if obj.format == 1  % QPSK
                % Store decision boundaries function in Parameters
                obj.params.set_param('Boundaries', @obj.qpsk_boundaries);
            else
                error('Only QPSK (format=1) supported');
            end
        end

        function bits = qpsk_boundaries(obj, sym)
            % Decision boundaries for QPSK
            % Returns [bit1, bit2] where:
            % bit1 = 0 if real(sym) > 0, 1 if real(sym) < 0
            % bit2 = 0 if imag(sym) > 0, 1 if imag(sym) < 0
            bits = [real(sym) < 0, imag(sym) < 0];
        end
    end
end
