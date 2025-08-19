classdef ConfigETx
    properties
        format (1,1) double = 1;  % Modulation format (1 = QPSK)
        params Parameters;        % Parameters object
    end

    methods
        function obj = ConfigETx(params, format)
            % Constructor
            if nargin < 2
                format = 1;  % Default to QPSK
            end
            obj.params = params;
            obj.format = format;
            obj.configure_modulation();
        end

        function configure_modulation(obj)
            % Configure modulation based on format
            if obj.format == 1  % QPSK
                obj.params.set_param('M', 4);
                obj.params.set_param('k', log2(obj.params.get_param('M')));
                obj.params.set_param('a', 1 / sqrt(2));  % Normalization constant for QPSK
                obj.params.set_param('FormatStr', "QPSK");

                % Compute derived parameters
                Nbits = obj.params.get_param('Nbits');
                k = obj.params.get_param('k');
                obj.params.set_param('Nsym', floor(Nbits / k));

                % Update sampling parameters
                Rb = obj.params.get_param('Rb');
                obj.params.set_param('Rs', Rb / obj.params.get_param('k'));
                obj.params.set_param('Ts', 1.0 / obj.params.get_param('Rs'));
                obj.params.set_param('fs', 8 * Rb);
                obj.params.set_param('ts', 1.0 / obj.params.get_param('fs'));
                obj.params.set_param('sps', obj.params.get_param('fs') / obj.params.get_param('Rs'));
            else
                error('Only QPSK (format=1) is supported for now.');
            end
        end
    end
end
