classdef TxDSP < handle
    properties
        symbols;  % Transmitted symbols
    end

    methods
        function obj = TxDSP()
            % Constructor
        end

        function [obj, symbols] = generate_signal(obj, params, bits)
            % Generate QPSK symbols from bits
            k = params.get_param('k');
            a = params.get_param('a');

            % Check if bits are divisible by k
            if mod(length(bits), k) ~= 0
                error('Number of bits must be divisible by k (bits per symbol).');
            end

            % Reshape bits into k rows (2 rows for QPSK)
            B = reshape(bits, k, [])';

            % Pre-allocate symbols array
            symbols = zeros(size(B, 1), 1, 'like', 1+1j);

            % QPSK mapping with Gray coding (more efficient implementation)
            for i = 1:size(B, 1)
                b1 = B(i, 1);  % First bit
                b2 = B(i, 2);  % Second bit

                % Gray-coded QPSK mapping using direct calculation
                I = (2*b1 - 1);  % BPSK for I channel (-1 or +1)
                Q = (2*b2 - 1);  % BPSK for Q channel (-1 or +1)
                symbols(i) = a * complex(I, Q);
            end

            % Save to Parameters and object property
            params.set_param('t_k', symbols);
            obj.symbols = symbols;
        end
    end
end
