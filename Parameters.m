classdef Parameters < handle
    properties
        SNR
        TxSignal
        RxSignal
        BER
        OriginalBits
        BitCount
    end
    methods
        function set_param(obj, name, value)
            if isprop(obj, name)
                obj.(name) = value;
            else
                error('Parameter %s does not exist.', name);
            end
        end
        function value = get_param(obj, name)
            if isprop(obj, name)
                value = obj.(name);
            else
                error('Parameter %s does not exist.', name);
            end
        end
    end
end
